import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let stocksVC = UINavigationController(rootViewController: StockListViewController())
        stocksVC.tabBarItem = UITabBarItem(
            title: "Stocks",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis")
        )

        let favouritesVC = UINavigationController(rootViewController: FavoritesViewController())
        favouritesVC.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )

        viewControllers = [stocksVC, favouritesVC]
        tabBar.tintColor = .black
        tabBar.backgroundColor = .white
    }
}
