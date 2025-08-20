import UIKit
import SnapKit

final class StockCardView: UIView {

    private let logoImageView = UIImageView()
    private let symbolLabel = UILabel()
    private let companyNameLabel = UILabel()
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()
    private let favouriteButton = UIButton(type: .system)

    var favouriteAction: (() -> Void)?

    init(stock: Stock, isFavourite: Bool = false) {
        super.init(frame: .zero)
        setupUI()
        configure(with: stock, isFavourite: isFavourite)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        clipsToBounds = true

        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layer.cornerRadius = 8
        logoImageView.clipsToBounds = true

        symbolLabel.font = UIFont(name: "Montserrat-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
        companyNameLabel.font = UIFont(name: "Montserrat-Regular", size: 12) ?? .systemFont(ofSize: 12)
        companyNameLabel.textColor = .secondaryLabel

        priceLabel.font = UIFont(name: "Montserrat-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
        changeLabel.font = UIFont(name: "Montserrat-SemiBold", size: 12) ?? .systemFont(ofSize: 12)

        favouriteButton.tintColor = .systemYellow
        favouriteButton.addTarget(self, action: #selector(favouriteTapped), for: .touchUpInside)

        let leftStack = UIStackView(arrangedSubviews: [symbolLabel, companyNameLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 2

        let rightStack = UIStackView(arrangedSubviews: [priceLabel, changeLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 2

        addSubview(logoImageView)
        addSubview(leftStack)
        addSubview(favouriteButton)
        addSubview(rightStack)

        logoImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        leftStack.snp.makeConstraints { make in
            make.left.equalTo(logoImageView.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        favouriteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        rightStack.snp.makeConstraints { make in
            make.right.equalTo(favouriteButton.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
    }

    func configure(with stock: Stock, isFavourite: Bool) {
        symbolLabel.text = stock.symbol
        companyNameLabel.text = stock.name
        priceLabel.text = "$\(String(format: "%.2f", stock.price))"

        if stock.change >= 0 {
            changeLabel.text = "+\(String(format: "%.2f", stock.change))"
            changeLabel.textColor = .systemGreen
        } else {
            changeLabel.text = "\(String(format: "%.2f", stock.change))"
            changeLabel.textColor = .systemRed
        }

        let favImg = isFavourite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        favouriteButton.setImage(favImg, for: .normal)

        if let url = URL(string: stock.logo) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async { self?.logoImageView.image = image }
            }.resume()
        } else {
            logoImageView.image = UIImage(systemName: "building.2")
        }
    }

    @objc private func favouriteTapped() {
        favouriteAction?()
    }
}
