import UIKit

@MainActor
protocol MovieRecommendationRoutingLogic {
    func routeBack()
    func routeToMovieDetails(movieID: Int)
}

@MainActor
final class MovieRecommendationRouter: MovieRecommendationRoutingLogic {
    weak var viewController: MovieRecommendationViewController?
    private let movieDetailsBuilder: MovieDetailsBuilding
    init(movieDetailsBuilder: MovieDetailsBuilding) {
        self.movieDetailsBuilder = movieDetailsBuilder
    }

    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func routeToMovieDetails(movieID: Int) {
        let details = movieDetailsBuilder.makeMovieDetails(movieId: movieID)
        viewController?.navigationController?.pushViewController(details, animated: true)
    }
}
