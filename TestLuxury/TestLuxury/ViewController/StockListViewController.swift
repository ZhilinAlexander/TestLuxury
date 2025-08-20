import UIKit
import SnapKit

final class StockListViewController: UIViewController {

    private var allStocks: [Stock] = []
    private var filteredStocks: [Stock] = []
    private var showingFavourites = false

    // MARK: - UI Elements
    private let headerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let searchContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 25
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.backgroundColor = .white
        return view
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Find company or ticker"
        sb.searchBarStyle = .minimal
        sb.backgroundImage = UIImage()
        sb.searchTextField.backgroundColor = .white
        sb.searchTextField.textColor = .black
        sb.searchTextField.tintColor = .black
        sb.searchTextField.borderStyle = .none
        return sb
    }()

    private let stocksButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Stocks", for: .normal)
        btn.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 28)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()

    private let favouriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Favourite", for: .normal)
        btn.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 18)
        btn.setTitleColor(.gray, for: .normal)
        return btn
    }()

    private let categoryContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        return stack
    }()

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let cellId = "StockCell"

    // MARK: - Scroll tracking
    private var searchHeight: CGFloat = 56
    private var previousOffset: CGFloat = 0

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupActions()
        updateCategoryUI()
        fetchStocks()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(headerContainer)
        headerContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }

        headerContainer.addSubview(searchContainer)
        searchContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(searchHeight)
        }

        searchContainer.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        searchBar.delegate = self

        categoryContainer.addArrangedSubview(stocksButton)
        categoryContainer.addArrangedSubview(favouriteButton)
        headerContainer.addSubview(categoryContainer)
        categoryContainer.snp.makeConstraints { make in
            make.top.equalTo(searchContainer.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(32)
            make.width.equalTo(207)
        }

        tableView.register(StockCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 70
        view.addSubview(tableView)
   //     tableView.snp.makeConstraints { make in
    //        make.top.equalTo(headerContainer.snp.bottom)
     //       make.left.right.bottom.equalToSuperview()
        tableView.snp.makeConstraints { make in
            make.top.equalTo(categoryContainer.snp.bottom).offset(8) // отступ
            make.left.equalToSuperview().offset(16)   //
            make.right.equalToSuperview().offset(-16) // отступы
            make.bottom.equalToSuperview()
        }

    }

    // MARK: - Actions
    private func setupActions() {
        stocksButton.addTarget(self, action: #selector(showStocks), for: .touchUpInside)
        favouriteButton.addTarget(self, action: #selector(showFavourites), for: .touchUpInside)
    }

    @objc private func showStocks() {
        showingFavourites = false
        updateCategoryUI()
        filteredStocks = allStocks
        tableView.reloadData()
    }

    @objc private func showFavourites() {
        showingFavourites = true
        updateCategoryUI()
        filteredStocks = CoreDataManager.shared.getAllFavourites()
        tableView.reloadData()
    }

    private func updateCategoryUI() {
        let stocksSize: CGFloat = showingFavourites ? 18 : 28
        let favSize: CGFloat = showingFavourites ? 28 : 18
        stocksButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: stocksSize) ?? .boldSystemFont(ofSize: stocksSize)
        favouriteButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: favSize) ?? .boldSystemFont(ofSize: favSize)

        stocksButton.setTitleColor(showingFavourites ? .gray : .black, for: .normal)
        favouriteButton.setTitleColor(showingFavourites ? .black : .gray, for: .normal)
    }

    // MARK: - Networking
    private func fetchStocks() {
        guard let url = URL(string: "https://mustdev.ru/api/stocks.json") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let stocks = try JSONDecoder().decode([Stock].self, from: data)
                    DispatchQueue.main.async {
                        self.allStocks = stocks
                        if !self.showingFavourites {
                            self.filteredStocks = stocks
                        }
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Ошибка декодирования:", error)
                }
            } else if let error = error {
                print("Ошибка запроса:", error)
            }
        }.resume()
    }
}

// MARK: - UITableView DataSource & Delegate
extension StockListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStocks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? StockCell else {
            return UITableViewCell()
        }

        let stock: Stock = filteredStocks[indexPath.row]
        let isFav = CoreDataManager.shared.isFavourite(symbol: stock.symbol)
        cell.configure(with: stock, isFavourite: isFav)

        cell.favouriteAction = { [weak self] _ in
            if CoreDataManager.shared.isFavourite(symbol: stock.symbol) {
                CoreDataManager.shared.deleteFavourite(symbol: stock.symbol)
            } else {
                CoreDataManager.shared.saveFavourite(stock: stock)
            }
            if self?.showingFavourites == true {
                self?.filteredStocks = CoreDataManager.shared.getAllFavourites()
            }
            self?.tableView.reloadData()
        }

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let progress = min(max(offsetY / searchHeight, 0), 1)

        // Поиск полностью уезжает
        searchContainer.transform = CGAffineTransform(translationX: 0, y: -progress * searchHeight)
        searchContainer.alpha = 1 - progress

        // Кнопки плавно поднимаются
        let buttonShift: CGFloat = 80
        categoryContainer.transform = CGAffineTransform(translationX: 0, y: -progress * buttonShift)

        // Таблица поднимается вместе
        let tableShift: CGFloat = 70
        tableView.transform = CGAffineTransform(translationX: 0, y: -progress * tableShift)
    }

}

// MARK: - UISearchBar Delegate
extension StockListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let baseArray = showingFavourites ? CoreDataManager.shared.getAllFavourites() : allStocks
        if searchText.isEmpty {
            filteredStocks = baseArray
        } else {
            filteredStocks = baseArray.filter {
                $0.symbol.lowercased().contains(searchText.lowercased()) ||
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let vc = SearchViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
