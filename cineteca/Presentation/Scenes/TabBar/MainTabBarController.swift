import UIKit

final class MainTabBarController: UITabBarController {
    private let repository: MovieRepositoryProtocol
    private let genreRepository: GenreRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let appearanceRepository: AppearanceRepositoryProtocol
    private let languageRepository: LanguageRepositoryProtocol
    private let movieDetailsBuilder: MovieDetailsBuilding

    init(
        repository: MovieRepositoryProtocol,
        genreRepository: GenreRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        appearanceRepository: AppearanceRepositoryProtocol,
        languageRepository: LanguageRepositoryProtocol,
        movieDetailsBuilder: MovieDetailsBuilding
    ) {
        self.repository = repository
        self.genreRepository = genreRepository
        self.userRepository = userRepository
        self.appearanceRepository = appearanceRepository
        self.languageRepository = languageRepository
        self.movieDetailsBuilder = movieDetailsBuilder
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTabs()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeDidChange),
            name: ThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        setupAppearance()
    }

    @objc private func handleThemeDidChange() {
        setupAppearance()
    }

    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appBackground

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
        let homeVC = HomeConfigurator.resolve(
            repository: repository,
            genreRepository: genreRepository,
            movieDetailsBuilder: movieDetailsBuilder
        )
        homeVC.tabBarItem = UITabBarItem(title: Strings.TabBar.home, image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))

        let searchVC = SearchConfigurator.resolve(
            repository: repository,
            genreRepository: genreRepository,
            movieDetailsBuilder: movieDetailsBuilder
        )
        searchVC.tabBarItem = UITabBarItem(
            title: Strings.TabBar.search,
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        let listsVC  = makePlaceholder(title: Strings.TabBar.lists,  icon: "bookmark")
        let statsVC  = makePlaceholder(title: Strings.TabBar.stats,  icon: "chart.bar")
        let profileVC = ProfileConfigurator.resolve(
            userRepository: userRepository,
            appearanceRepository: appearanceRepository,
            languageRepository: languageRepository
        )
        profileVC.tabBarItem = UITabBarItem(
            title: Strings.TabBar.profile,
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

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
