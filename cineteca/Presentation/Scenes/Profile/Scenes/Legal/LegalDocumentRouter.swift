import UIKit

protocol LegalDocumentRoutingLogic {
    func routeBack()
}

final class LegalDocumentRouter {
    weak var viewController: UIViewController?
}

extension LegalDocumentRouter: LegalDocumentRoutingLogic {
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
