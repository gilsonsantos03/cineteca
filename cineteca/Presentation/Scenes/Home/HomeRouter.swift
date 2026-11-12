import UIKit

@MainActor
protocol HomeRoutingLogic {
    func routeToTrailer(youtubeKey: String)
    func routeToMovieDetails(movieId: Int)
    func routeToMovieCatalog(category: MovieCollectionCategory, title: String)
    func routeToMovieRecommendation()
}

@MainActor
final class HomeRouter {
    weak var viewController: HomeViewController?
    private let movieDetailsBuilder: MovieDetailsBuilding
    private let movieCatalogBuilder: MovieCatalogBuilding
    private let movieRecommendationBuilder: MovieRecommendationBuilding

    init(
        movieDetailsBuilder: MovieDetailsBuilding,
        movieCatalogBuilder: MovieCatalogBuilding,
        movieRecommendationBuilder: MovieRecommendationBuilding
    ) {
        self.movieDetailsBuilder = movieDetailsBuilder
        self.movieCatalogBuilder = movieCatalogBuilder
        self.movieRecommendationBuilder = movieRecommendationBuilder
    }
}

extension HomeRouter: HomeRoutingLogic {
    func routeToTrailer(youtubeKey: String) {
        guard
            let appURL = URL(string: "youtube://watch?v=\(youtubeKey)"),
            let webURL = URL(string: "https://www.youtube.com/watch?v=\(youtubeKey)")
        else { return }

        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else {
            UIApplication.shared.open(webURL)
        }
    }

    func routeToMovieDetails(movieId: Int) {
        let viewController = movieDetailsBuilder.makeMovieDetails(movieId: movieId)
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }

    func routeToMovieCatalog(category: MovieCollectionCategory, title: String) {
        let viewController = movieCatalogBuilder.makeMovieCatalog(
            category: category,
            title: title
        )
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }

    func routeToMovieRecommendation() {
        let viewController = movieRecommendationBuilder.makeMovieRecommendation()
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}
