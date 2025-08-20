import UIKit
import SnapKit

final class StockSectionView: UIView {

    // MARK: - Data
    var stocks: [Stock] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - Callbacks
    var onShowMore: (() -> Void)?
    var onToggleFavourite: ((Stock) -> Void)?

    // MARK: - UI
    private let headerView = UIView()
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Stocks"
        l.font = UIFont(name: "Montserrat-Bold", size: 20) ?? .boldSystemFont(ofSize: 20)
        l.textColor = .black
        return l
    }()

    private let showMoreButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Show more", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        b.setTitleColor(.black, for: .normal)
        return b
    }()

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let cellId = "StockCell"

    // MARK: - Public API
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .white

        // Header
        addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(showMoreButton)

        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        showMoreButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        showMoreButton.addTarget(self, action: #selector(showMoreTapped), for: .touchUpInside)

        // Table
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        tableView.register(StockCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.isScrollEnabled = true   // теперь скроллится сама таблица
    }

    @objc private func showMoreTapped() {
        onShowMore?()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension StockSectionView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? StockCell else {
            return UITableViewCell()
        }

        let stock = stocks[indexPath.row]

        cell.configure(with: stock, isFavourite: false)

        cell.favouriteAction = { [weak self] isFavourite in
            self?.onToggleFavourite?(stock)
        }

        return cell
    }
}
