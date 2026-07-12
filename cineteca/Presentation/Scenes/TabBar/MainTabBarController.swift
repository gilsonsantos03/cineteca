import UIKit

final class MainTabBarController: UITabBarController {
    private let repository: MovieRepositoryProtocol
    private let genreRepository: GenreRepositoryProtocol

    init(repository: MovieRepositoryProtocol, genreRepository: GenreRepositoryProtocol) {
        self.repository = repository
        self.genreRepository = genreRepository
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
        let homeVC = HomeConfigurator.resolve(repository: repository, genreRepository: genreRepository)
        homeVC.tabBarItem = UITabBarItem(title: Strings.TabBar.home, image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))

        let searchVC = makePlaceholder(title: Strings.TabBar.search, icon: "magnifyingglass")
        let listsVC  = makePlaceholder(title: Strings.TabBar.lists,  icon: "bookmark")
        let statsVC  = makePlaceholder(title: Strings.TabBar.stats,  icon: "chart.bar")
        let profileVC = makePlaceholder(title: Strings.TabBar.profile, icon: "person")

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
