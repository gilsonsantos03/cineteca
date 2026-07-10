import UIKit

final class MainTabBarController: UITabBarController {
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTabs()
    }

    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)

        let normalAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.textSecondary
        ]
        let selectedAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.accentYellow
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = .textSecondary
        appearance.stackedLayoutAppearance.selected.iconColor = .accentYellow
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttr
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttr

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func setupTabs() {
        let homeVC = HomeConfigurator.resolve(repository: repository)
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))

        let searchVC = makePlaceholder(title: "Search", icon: "magnifyingglass")
        let listsVC  = makePlaceholder(title: "Lists",  icon: "bookmark")
        let statsVC  = makePlaceholder(title: "Stats",  icon: "chart.bar")
        let profileVC = makePlaceholder(title: "Profile", icon: "person")

        viewControllers = [homeVC, searchVC, listsVC, statsVC, profileVC].map {
            UINavigationController(rootViewController: $0)
        }
    }

    private func makePlaceholder(title: String, icon: String) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .appBackground
        vc.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), selectedImage: nil)
        return vc
    }
}
