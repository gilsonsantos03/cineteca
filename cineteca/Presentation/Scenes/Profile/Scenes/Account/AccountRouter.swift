import UIKit

protocol AccountRoutingLogic {
    func routeBack()
    func routeToChangePassword()
}

final class AccountRouter {
    weak var viewController: UIViewController?
    private let changePasswordBuilder: ChangePasswordBuilding

    init(changePasswordBuilder: ChangePasswordBuilding) {
        self.changePasswordBuilder = changePasswordBuilder
    }
}

extension AccountRouter: AccountRoutingLogic {
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func routeToChangePassword() {
        let changePasswordViewController = changePasswordBuilder.makeChangePassword()
        viewController?.navigationController?.pushViewController(changePasswordViewController, animated: true)
    }
}
