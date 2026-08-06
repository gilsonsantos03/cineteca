import UIKit

protocol HomeRoutingLogic {
    func routeToTrailer(youtubeKey: String)
}

final class HomeRouter {
    weak var viewController: HomeViewController?
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
}
