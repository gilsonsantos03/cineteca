import UIKit

protocol ChangePasswordRoutingLogic {
    func routeBack()
}

final class ChangePasswordRouter {
    weak var viewController: UIViewController?
}

extension ChangePasswordRouter: ChangePasswordRoutingLogic {
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
