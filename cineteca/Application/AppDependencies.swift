import Foundation
import UIKit

final class AppDependencies {
    let movieRepository: MovieRepositoryProtocol
    let genreRepository: GenreRepositoryProtocol
    let userRepository: UserRepositoryProtocol
    let statsRepository: StatsRepositoryProtocol
    let appearanceRepository: AppearanceRepositoryProtocol
    let languageRepository: LanguageRepositoryProtocol

    private let coreDataStack: CoreDataStack

    init() {
        self.languageRepository = LanguageRepository()
        let networkService = AppDependencies.makeTMDBNetworkService(languageRepository: languageRepository)
        self.coreDataStack = CoreDataStack()
        self.genreRepository = GenreRepository(networkService: networkService)
        self.movieRepository = MovieRepository(networkService: networkService)
        self.userRepository = UserRepository(coreDataStack: coreDataStack)
        self.statsRepository = StatsRepository()
        self.appearanceRepository = AppearanceRepository()
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
            userRepository: userRepository,
            statsRepository: statsRepository,
            movieDetailsBuilder: self,
            editProfileBuilder: self,
            accountBuilder: self,
            appearanceBuilder: self,
            languageBuilder: self,
            legalBuilder: self
        )
    }
}

extension AppDependencies:
    MovieDetailsBuilding,
    EditProfileBuilding,
    AccountBuilding,
    AppearanceBuilding,
    LanguageBuilding,
    LegalBuilding,
    ChangePasswordBuilding,
    LegalDocumentBuilding {
    func makeMovieDetails(movieId: Int) -> UIViewController {
        MovieDetailsConfigurator.resolve(
            movieId: movieId,
            repository: movieRepository,
            movieDetailsBuilder: self
        )
    }

    func makeEditProfile() -> UIViewController {
        EditProfileConfigurator.resolve(userRepository: userRepository)
    }

    func makeAccount() -> UIViewController {
        AccountConfigurator.resolve(
            userRepository: userRepository,
            changePasswordBuilder: self
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

    func makeChangePassword() -> UIViewController {
        ChangePasswordConfigurator.resolve(userRepository: userRepository)
    }

    func makeLegalDocument(documentType: LegalDocumentType) -> UIViewController {
        LegalDocumentConfigurator.resolve(documentType: documentType)
    }
}
