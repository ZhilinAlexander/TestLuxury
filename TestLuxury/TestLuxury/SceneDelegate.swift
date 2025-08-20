import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let tabBarController = UITabBarController()
        
        let stocksVC = UINavigationController(rootViewController: StockListViewController())
        
        let favVC = UINavigationController(rootViewController: FavoritesViewController())
        tabBarController.viewControllers = [stocksVC, favVC]
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }

}
