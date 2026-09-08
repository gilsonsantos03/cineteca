import UIKit

protocol AccountRoutingLogic {
    func routeBack()
    func routeToChangePassword()
}

final class AccountRouter {
    weak var viewController: UIViewController?
    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
}

extension AccountRouter: AccountRoutingLogic {
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func routeToChangePassword() {
        let changePasswordViewController = ChangePasswordConfigurator.resolve(userRepository: userRepository)
        viewController?.navigationController?.pushViewController(changePasswordViewController, animated: true)
    }
}
