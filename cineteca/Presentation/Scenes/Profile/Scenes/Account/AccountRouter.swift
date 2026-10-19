import UIKit

protocol AccountRoutingLogic {
    func routeBack()
}

final class AccountRouter {
    weak var viewController: UIViewController?

    init() {}
}

extension AccountRouter: AccountRoutingLogic {
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
