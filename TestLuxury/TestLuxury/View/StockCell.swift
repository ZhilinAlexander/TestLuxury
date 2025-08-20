import UIKit
import SnapKit

final class StockCell: UITableViewCell {

    // MARK: - Properties
    var favouriteAction: ((Bool) -> Void)? // передаем новое состояние избранного

    private let logoImageView = UIImageView()
    private let symbolLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()
    private let favButton = UIButton(type: .system)
    
    private var isFavorite = false // состояние кнопки

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupUI() {
        selectionStyle = .none

        // Логотип
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layer.cornerRadius = 12
        logoImageView.clipsToBounds = true
        contentView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(12)
            make.width.height.equalTo(52)
            make.bottom.lessThanOrEqualToSuperview().offset(-12) // для авторазмера
        }

        // Символ (тикер)
        symbolLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        symbolLabel.textColor = .black
        contentView.addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalTo(logoImageView.snp.right).offset(12)
        }

        // Кнопка избранного рядом с тикером
        favButton.setImage(UIImage(systemName: "star"), for: .normal)
        favButton.tintColor = .gray
        favButton.addTarget(self, action: #selector(favTapped), for: .touchUpInside)
        contentView.addSubview(favButton)
        favButton.snp.makeConstraints { make in
            make.centerY.equalTo(symbolLabel)
            make.left.equalTo(symbolLabel.snp.right).offset(8)
            make.width.height.equalTo(20)
        }

        // Название компании
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        nameLabel.textColor = .gray
        nameLabel.numberOfLines = 1
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(symbolLabel.snp.bottom).offset(2)
            make.left.equalTo(symbolLabel)
            make.right.lessThanOrEqualToSuperview().offset(-100) // не залезать на цену
        }

        // Цена (справа сверху)
        priceLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        priceLabel.textAlignment = .right
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-16)
        }

        // Процент изменения (справа снизу под ценой)
        changeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        changeLabel.textAlignment = .right
        contentView.addSubview(changeLabel)
        changeLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12) // фиксируем низ
        }
    }

    // MARK: - Configure
    func configure(with stock: Stock, isFavourite: Bool) {
        symbolLabel.text = stock.symbol
        nameLabel.text = stock.name
        priceLabel.text = String(format: "$%.2f", stock.price)
        changeLabel.text = String(format: "%+.2f%%", stock.changePercent)
        changeLabel.textColor = stock.changePercent >= 0 ? .systemGreen : .systemRed
        
        isFavorite = isFavourite
        updateFavButton()

        if let url = URL(string: stock.logo) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.logoImageView.image = image
                    }
                }
            }
        }
    }

    // MARK: - Actions
    @objc private func favTapped() {
        isFavorite.toggle()
        updateFavButton()
        favouriteAction?(isFavorite)
    }

    private func updateFavButton() {
        let imageName = isFavorite ? "star.fill" : "star"
        let color = isFavorite ? UIColor.systemYellow : UIColor.gray

        UIView.transition(with: favButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.favButton.setImage(UIImage(systemName: imageName), for: .normal)
            self.favButton.tintColor = color
        }, completion: nil)

        UIView.animate(withDuration: 0.15, animations: {
            self.favButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.favButton.transform = .identity
            }
        }
    }
}
