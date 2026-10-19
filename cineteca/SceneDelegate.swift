import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard
            let windowScene = scene as? UIWindowScene,
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let dependencies = appDelegate.dependencies
        else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = dependencies.makeRootViewController()
        self.window = window
        appDelegate.window = window
        window.makeKeyAndVisible()

        ThemeManager.apply(dependencies.appearanceRepository.fetchSelectedTheme())
    }
}
