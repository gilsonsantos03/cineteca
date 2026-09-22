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
            appearanceRepository: appearanceRepository,
            languageRepository: languageRepository,
            movieDetailsBuilder: self
        )
    }
}

extension AppDependencies: MovieDetailsBuilding {
    func makeMovieDetails(movieId: Int) -> UIViewController {
        MovieDetailsConfigurator.resolve(
            movieId: movieId,
            repository: movieRepository,
            movieDetailsBuilder: self
        )
    }
}
