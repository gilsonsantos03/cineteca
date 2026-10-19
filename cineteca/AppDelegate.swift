import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var dependencies: AppDependencies?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard FirebaseConfiguration.configureIfPossible() else {
            return false
        }
        let dependencies = AppDependencies()
        self.dependencies = dependencies

        let selectedLanguage = dependencies.languageRepository.fetchSelectedLanguage()
        LanguageManager.bootstrap(selectedLanguage: selectedLanguage)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = dependencies.makeRootViewController()
        window?.makeKeyAndVisible()
        ThemeManager.apply(dependencies.appearanceRepository.fetchSelectedTheme())
        return true
    }

    func reloadApplication(selectingTabIndex: Int? = nil) {
        guard let window, let dependencies else { return }

        let selectedLanguage = dependencies.languageRepository.fetchSelectedLanguage()
        LanguageManager.bootstrap(selectedLanguage: selectedLanguage)

        let rootViewController = dependencies.makeRootViewController()
        ThemeManager.apply(dependencies.appearanceRepository.fetchSelectedTheme())
        window.rootViewController = rootViewController

        if let selectingTabIndex,
           let tabBarController = rootViewController as? UITabBarController {
            tabBarController.selectedIndex = selectingTabIndex
        }
    }
}
