import UIKit

final class MainTabBarController: UITabBarController {
    private let repository: MovieRepositoryProtocol
    private let genreRepository: GenreRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let statsRepository: StatsRepositoryProtocol
    private let movieDetailsBuilder: MovieDetailsBuilding
    private let editProfileBuilder: EditProfileBuilding
    private let accountBuilder: AccountBuilding
    private let appearanceBuilder: AppearanceBuilding
    private let languageBuilder: LanguageBuilding
    private let legalBuilder: LegalBuilding

    init(
        repository: MovieRepositoryProtocol,
        genreRepository: GenreRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        statsRepository: StatsRepositoryProtocol,
        movieDetailsBuilder: MovieDetailsBuilding,
        editProfileBuilder: EditProfileBuilding,
        accountBuilder: AccountBuilding,
        appearanceBuilder: AppearanceBuilding,
        languageBuilder: LanguageBuilding,
        legalBuilder: LegalBuilding
    ) {
        self.repository = repository
        self.genreRepository = genreRepository
        self.userRepository = userRepository
        self.statsRepository = statsRepository
        self.movieDetailsBuilder = movieDetailsBuilder
        self.editProfileBuilder = editProfileBuilder
        self.accountBuilder = accountBuilder
        self.appearanceBuilder = appearanceBuilder
        self.languageBuilder = languageBuilder
        self.legalBuilder = legalBuilder
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
        let statsVC = StatsConfigurator.resolve(statsRepository: statsRepository)
        statsVC.tabBarItem = UITabBarItem(
            title: Strings.TabBar.stats,
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        let profileVC = ProfileConfigurator.resolve(
            userRepository: userRepository,
            editProfileBuilder: editProfileBuilder,
            accountBuilder: accountBuilder,
            appearanceBuilder: appearanceBuilder,
            languageBuilder: languageBuilder,
            legalBuilder: legalBuilder
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
