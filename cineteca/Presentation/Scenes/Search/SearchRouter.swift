import UIKit

@MainActor
protocol SearchRoutingLogic {
    func routeToMovieDetails(movieId: Int)
}

@MainActor
final class SearchRouter {
    weak var viewController: SearchViewController?
    private let movieDetailsBuilder: MovieDetailsBuilding

    init(movieDetailsBuilder: MovieDetailsBuilding) {
        self.movieDetailsBuilder = movieDetailsBuilder
    }
}

extension SearchRouter: SearchRoutingLogic {
    func routeToMovieDetails(movieId: Int) {
        let viewController = movieDetailsBuilder.makeMovieDetails(movieId: movieId)
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}
