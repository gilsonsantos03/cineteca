import Foundation
import UIKit

@MainActor
final class AppDependencies {
    let movieRepository: MovieRepositoryProtocol
    let genreRepository: GenreRepositoryProtocol
    let movieActivityRepository: MovieActivityRepositoryProtocol
    let userRepository: UserRepositoryProtocol
    let statsRepository: StatsRepositoryProtocol
    let appearanceRepository: AppearanceRepositoryProtocol
    let languageRepository: LanguageRepositoryProtocol
    let movieReviewSheetFactory: MovieReviewSheetBuilding
    let authRepository: AuthRepositoryProtocol
    let authenticationCoordinator: AuthenticationCoordinator

    init() {
        FirebaseConfiguration.configureIfPossible()
        self.languageRepository = LanguageRepository()
        let networkService = AppDependencies.makeTMDBNetworkService(languageRepository: languageRepository)
        self.genreRepository = GenreRepository(networkService: networkService)
        self.movieRepository = MovieRepository(networkService: networkService)
        let activityRepository = FirestoreMovieActivityRepository()
        self.movieActivityRepository = activityRepository
        let userRepository = FirestoreUserRepository(activityRepository: activityRepository)
        self.userRepository = userRepository
        self.statsRepository = FirestoreStatsRepository(activityRepository: activityRepository)
        self.appearanceRepository = AppearanceRepository()
        self.movieReviewSheetFactory = MovieReviewSheetFactory()
        let authRepository = FirebaseAuthRepository()
        self.authRepository = authRepository
        self.authenticationCoordinator = AuthenticationCoordinator(
            authRepository: authRepository,
            userRepository: userRepository,
            providers: [],
            presenterProvider: {
                AppDependencies.topViewController(from: nil)
            }
        )
    }

    private static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }

    @MainActor
    private static func topViewController(
        from viewController: UIViewController?
    ) -> UIViewController? {
        let viewController = viewController ?? keyWindow?.rootViewController
        if let presented = viewController?.presentedViewController {
            return topViewController(from: presented)
        }
        if let navigation = viewController as? UINavigationController {
            return topViewController(from: navigation.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            return topViewController(from: tab.selectedViewController)
        }
        return viewController
    }

    private static func makeTMDBNetworkService(
        languageRepository: LanguageRepositoryProtocol
    ) -> NetworkServiceProtocol {
        guard let token = APIKeys.apiKey, !token.isEmpty else {
            fatalError("Missing TMDB token. Add API_KEY to Keys.plist.")
        }

        guard let baseURL = URL(string: "https://api.themoviedb.org/3") else {
            fatalError("Invalid TMDB base URL.")
        }

        let configuration = NetworkConfiguration(
            baseURL: baseURL,
            defaultHeaders: [
                "Authorization": "Bearer \(token)",
                "accept": "application/json"
            ]
        )

        return NetworkService(
            configuration: configuration,
            localeProvider: LocaleProvider(languageRepository: languageRepository)
        )
    }
}

extension AppDependencies {
    func makeRootViewController() -> UIViewController {
        MainTabBarController(
            repository: movieRepository,
            genreRepository: genreRepository,
            movieActivityRepository: movieActivityRepository,
            userRepository: userRepository,
            statsRepository: statsRepository,
            movieDetailsBuilder: self,
            movieCatalogBuilder: self,
            listsBuilder: self,
            editProfileBuilder: self,
            myReviewsBuilder: self,
            accountBuilder: self,
            appearanceBuilder: self,
            languageBuilder: self,
            legalBuilder: self,
            authGate: authenticationCoordinator
        )
    }
}

extension AppDependencies:
    MovieDetailsBuilding,
    MovieCatalogBuilding,
    EditProfileBuilding,
    SearchBuilding,
    MyReviewsBuilding,
    ListsBuilding,
    AccountBuilding,
    AppearanceBuilding,
    LanguageBuilding,
    LegalBuilding,
    LegalDocumentBuilding {
    func makeMovieDetails(movieId: Int) -> UIViewController {
        MovieDetailsConfigurator.resolve(
            movieId: movieId,
            repository: movieRepository,
            activityRepository: movieActivityRepository,
            movieDetailsBuilder: self,
            movieReviewSheetFactory: movieReviewSheetFactory,
            authGate: authenticationCoordinator
        )
    }

    func makeMovieCatalog(category: MovieCollectionCategory, title: String) -> UIViewController {
        MovieCatalogConfigurator.resolve(
            category: category,
            title: title,
            repository: movieRepository,
            genreRepository: genreRepository,
            movieDetailsBuilder: self
        )
    }

    func makeEditProfile() -> UIViewController {
        EditProfileConfigurator.resolve(
            userRepository: userRepository,
            searchBuilder: self,
            authGate: authenticationCoordinator
        )
    }

    func makeSearch(
        selectionBehavior: SearchModels.SelectionBehavior,
        selectionDelegate: SearchSelectionDelegate?
    ) -> UIViewController {
        SearchConfigurator.resolve(
            repository: movieRepository,
            genreRepository: genreRepository,
            movieDetailsBuilder: self,
            selectionBehavior: selectionBehavior,
            selectionDelegate: selectionDelegate
        )
    }

    func makeMyReviews() -> UIViewController {
        MyReviewsConfigurator.resolve(
            userRepository: userRepository,
            activityRepository: movieActivityRepository,
            movieReviewSheetFactory: movieReviewSheetFactory,
            authGate: authenticationCoordinator
        )
    }

    func makeLists() -> UIViewController {
        ListsConfigurator.resolve(
            activityRepository: movieActivityRepository,
            movieDetailsBuilder: self,
            authGate: authenticationCoordinator
        )
    }

    func makeAccount() -> UIViewController {
        AccountConfigurator.resolve(
            userRepository: userRepository,
            authRepository: authRepository,
            authGate: authenticationCoordinator
        )
    }

    func makeAppearance() -> UIViewController {
        AppearanceConfigurator.resolve(appearanceRepository: appearanceRepository)
    }

    func makeLanguage() -> UIViewController {
        LanguageConfigurator.resolve(languageRepository: languageRepository)
    }

    func makeLegal() -> UIViewController {
        LegalConfigurator.resolve(legalDocumentBuilder: self)
    }

    func makeLegalDocument(documentType: LegalDocumentType) -> UIViewController {
        LegalDocumentConfigurator.resolve(documentType: documentType)
    }
}
