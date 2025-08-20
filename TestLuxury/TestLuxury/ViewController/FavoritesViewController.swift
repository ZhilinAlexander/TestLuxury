import UIKit
import SnapKit

final class FavoritesViewController: UIViewController {

    private var favourites: [Stock] = []
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Favourites"

        setupTable()
        loadFavourites()

        // Подписка на изменения избранного
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadFavourites),
                                               name: .favouritesUpdated,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupTable() {
        tableView.separatorStyle = .none
        tableView.rowHeight = 70
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StockCell.self, forCellReuseIdentifier: "StockCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func loadFavourites() {
        favourites = CoreDataManager.shared.getAllFavourites()
        tableView.reloadData()
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath) as? StockCell else {
            return UITableViewCell()
        }

        let stock = favourites[indexPath.row]

        // Настраиваем ячейку как избранную
        cell.configure(with: stock, isFavourite: true)

        // Замыкание с передачей состояния кнопки
        cell.favouriteAction = { [weak self] isFav in
            if !isFav {
                CoreDataManager.shared.deleteFavourite(symbol: stock.symbol)
                NotificationCenter.default.post(name: .favouritesUpdated, object: nil)
            }
        }

        return cell
    }
}

// MARK: - Notification Name
extension Notification.Name {
    static let favouritesUpdated = Notification.Name("favouritesUpdated")
}
