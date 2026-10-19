import UIKit

@MainActor
protocol MovieCatalogRoutingLogic {
    func routeToMovieDetails(movieId: Int)
}

@MainActor
final class MovieCatalogRouter {
    weak var viewController: MovieCatalogViewController?
    private let movieDetailsBuilder: MovieDetailsBuilding

    init(movieDetailsBuilder: MovieDetailsBuilding) {
        self.movieDetailsBuilder = movieDetailsBuilder
    }
}

extension MovieCatalogRouter: MovieCatalogRoutingLogic {
    func routeToMovieDetails(movieId: Int) {
        let viewController = movieDetailsBuilder.makeMovieDetails(movieId: movieId)
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}
