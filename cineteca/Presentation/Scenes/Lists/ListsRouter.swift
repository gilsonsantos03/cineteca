import UIKit

protocol ListsRoutingLogic {
    func routeToMovieDetails(movieId: Int)
}

final class ListsRouter {
    weak var viewController: ListsViewController?
    private let movieDetailsBuilder: MovieDetailsBuilding

    init(movieDetailsBuilder: MovieDetailsBuilding) {
        self.movieDetailsBuilder = movieDetailsBuilder
    }
}

extension ListsRouter: ListsRoutingLogic {
    func routeToMovieDetails(movieId: Int) {
        let viewController = movieDetailsBuilder.makeMovieDetails(movieId: movieId)
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}
