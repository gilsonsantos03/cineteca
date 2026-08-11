import Foundation
import UIKit

final class AppDependencies {
    let movieRepository: MovieRepositoryProtocol
    let genreRepository: GenreRepositoryProtocol

    init() {
        let networkService = AppDependencies.makeTMDBNetworkService()
        let localeProvider = LocaleProvider()
        let genreRepository = GenreRepository(
            networkService: networkService,
            localeProvider: localeProvider
        )
        self.genreRepository = genreRepository
        self.movieRepository = MovieRepository(
            networkService: networkService,
            localeProvider: localeProvider
        )
    }

    private static func makeTMDBNetworkService() -> NetworkServiceProtocol {
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

        return NetworkService(configuration: configuration)
    }
}

extension AppDependencies {
    func makeRootViewController() -> UIViewController {
        MainTabBarController(
            repository: movieRepository,
            genreRepository: genreRepository,
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
