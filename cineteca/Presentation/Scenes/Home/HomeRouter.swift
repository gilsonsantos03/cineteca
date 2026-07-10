import UIKit

protocol HomeRoutingLogic {}

final class HomeRouter {
    weak var viewController: HomeViewController?
}

extension HomeRouter: HomeRoutingLogic {}
