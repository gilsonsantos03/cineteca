import UIKit

protocol AuthenticationRoutingLogic: AnyObject {
    func routeBack()
}

final class AuthenticationRouter: AuthenticationRoutingLogic {
    weak var viewController: UIViewController?

    func routeBack() {
        viewController?.dismiss(animated: true)
    }
}
