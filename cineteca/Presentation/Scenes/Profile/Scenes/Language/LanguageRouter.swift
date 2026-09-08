import UIKit

protocol LanguageRoutingLogic {
    func routeBack()
    func routeAfterApply()
}

final class LanguageRouter {
    weak var viewController: UIViewController?
}

extension LanguageRouter: LanguageRoutingLogic {
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func routeAfterApply() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            routeBack()
            return
        }
        appDelegate.reloadApplication(selectingTabIndex: 4)
    }
}
