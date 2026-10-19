import UIKit

final class MainTabBarController: UITabBarController {
    private let repository: MovieRepositoryProtocol
    private let genreRepository: GenreRepositoryProtocol
    private let movieActivityRepository: MovieActivityRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let statsRepository: StatsRepositoryProtocol
    private let movieDetailsBuilder: MovieDetailsBuilding
    private let movieCatalogBuilder: MovieCatalogBuilding
    private let listsBuilder: ListsBuilding
    private let editProfileBuilder: EditProfileBuilding
    private let myReviewsBuilder: MyReviewsBuilding
    private let accountBuilder: AccountBuilding
    private let appearanceBuilder: AppearanceBuilding
    private let languageBuilder: LanguageBuilding
    private let legalBuilder: LegalBuilding
    private let authGate: AuthenticationGateProtocol
    private let authRepository: AuthRepositoryProtocol

    init(
        repository: MovieRepositoryProtocol,
        genreRepository: GenreRepositoryProtocol,
        movieActivityRepository: MovieActivityRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        statsRepository: StatsRepositoryProtocol,
        movieDetailsBuilder: MovieDetailsBuilding,
        movieCatalogBuilder: MovieCatalogBuilding,
        listsBuilder: ListsBuilding,
        editProfileBuilder: EditProfileBuilding,
        myReviewsBuilder: MyReviewsBuilding,
        accountBuilder: AccountBuilding,
        appearanceBuilder: AppearanceBuilding,
        languageBuilder: LanguageBuilding,
        legalBuilder: LegalBuilding,
        authGate: AuthenticationGateProtocol,
        authRepository: AuthRepositoryProtocol
    ) {
        self.repository = repository
        self.genreRepository = genreRepository
        self.movieActivityRepository = movieActivityRepository
        self.userRepository = userRepository
        self.statsRepository = statsRepository
        self.movieDetailsBuilder = movieDetailsBuilder
        self.movieCatalogBuilder = movieCatalogBuilder
        self.listsBuilder = listsBuilder
        self.editProfileBuilder = editProfileBuilder
        self.myReviewsBuilder = myReviewsBuilder
        self.accountBuilder = accountBuilder
        self.appearanceBuilder = appearanceBuilder
        self.languageBuilder = languageBuilder
        self.legalBuilder = legalBuilder
        self.authGate = authGate
        self.authRepository = authRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

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
            activityRepository: movieActivityRepository,
            movieDetailsBuilder: movieDetailsBuilder,
            movieCatalogBuilder: movieCatalogBuilder,
            authGate: authGate
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

        let listsVC = listsBuilder.makeLists()
        listsVC.tabBarItem = UITabBarItem(
            title: Strings.TabBar.lists,
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )
        let statsVC = StatsConfigurator.resolve(
            statsRepository: statsRepository,
            authGate: authGate
        )
        statsVC.tabBarItem = UITabBarItem(
            title: Strings.TabBar.stats,
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        let profileVC = ProfileConfigurator.resolve(
            userRepository: userRepository,
            movieDetailsBuilder: movieDetailsBuilder,
            editProfileBuilder: editProfileBuilder,
            myReviewsBuilder: myReviewsBuilder,
            accountBuilder: accountBuilder,
            appearanceBuilder: appearanceBuilder,
            languageBuilder: languageBuilder,
            legalBuilder: legalBuilder,
            authGate: authGate,
            authRepository: authRepository
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

}
