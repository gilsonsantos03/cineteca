import UIKit

protocol HomeRoutingLogic {
    func routeToTrailer(youtubeKey: String)
    func routeToMovieDetails(movieId: Int)
    func routeToMovieCatalog(category: MovieCollectionCategory, title: String)
}

final class HomeRouter {
    weak var viewController: HomeViewController?
    private let movieDetailsBuilder: MovieDetailsBuilding
    private let movieCatalogBuilder: MovieCatalogBuilding

    init(
        movieDetailsBuilder: MovieDetailsBuilding,
        movieCatalogBuilder: MovieCatalogBuilding
    ) {
        self.movieDetailsBuilder = movieDetailsBuilder
        self.movieCatalogBuilder = movieCatalogBuilder
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
}
