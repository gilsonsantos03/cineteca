import UIKit

protocol AppearanceRoutingLogic {
    func routeBack()
}

final class AppearanceRouter {
    weak var viewController: UIViewController?
}

extension AppearanceRouter: AppearanceRoutingLogic {
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
