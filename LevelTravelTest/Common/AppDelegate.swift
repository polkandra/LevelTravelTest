
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let networkManager = NetworkManager()
        let mainPresenter = MainPresenter(networkManager: networkManager)
        let appStartVC = MainViewController(mainPresenter: mainPresenter)
        let navController = UINavigationController(rootViewController: appStartVC)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

