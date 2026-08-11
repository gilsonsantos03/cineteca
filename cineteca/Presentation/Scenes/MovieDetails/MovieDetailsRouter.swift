import UIKit

protocol MovieDetailsRoutingLogic {
    func routeBack()
    func routeToTrailer(youtubeKey: String)
    func routeToMovieDetails(movieId: Int)
}

final class MovieDetailsRouter {
    weak var viewController: MovieDetailsViewController?
    private let movieDetailsBuilder: MovieDetailsBuilding

    init(movieDetailsBuilder: MovieDetailsBuilding) {
        self.movieDetailsBuilder = movieDetailsBuilder
    }
}

extension MovieDetailsRouter: MovieDetailsRoutingLogic {
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }

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
}
