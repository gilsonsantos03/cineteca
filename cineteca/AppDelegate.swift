import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let dependencies = AppDependencies()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let selectedLanguage = dependencies.languageRepository.fetchSelectedLanguage()
        LanguageManager.bootstrap(selectedLanguage: selectedLanguage)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = dependencies.makeRootViewController()
        window?.makeKeyAndVisible()
        ThemeManager.apply(dependencies.appearanceRepository.fetchSelectedTheme())
        return true
    }

    func reloadApplication(selectingTabIndex: Int? = nil) {
        guard let window else { return }

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
