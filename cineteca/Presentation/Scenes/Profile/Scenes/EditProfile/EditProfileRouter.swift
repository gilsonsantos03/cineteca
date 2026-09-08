import UIKit

protocol EditProfileRoutingLogic {
    func routeBack()
}

final class EditProfileRouter {
    weak var viewController: UIViewController?
}

extension EditProfileRouter: EditProfileRoutingLogic {
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
