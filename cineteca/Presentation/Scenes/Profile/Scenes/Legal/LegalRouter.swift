import UIKit

protocol LegalRoutingLogic {
    func routeBack()
    func routeToPrivacyPolicy()
    func routeToTermsOfService()
}

final class LegalRouter {
    weak var viewController: UIViewController?
}

extension LegalRouter: LegalRoutingLogic {
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func routeToPrivacyPolicy() {
        let documentViewController = LegalDocumentConfigurator.resolve(documentType: .privacyPolicy)
        viewController?.navigationController?.pushViewController(documentViewController, animated: true)
    }

    func routeToTermsOfService() {
        let documentViewController = LegalDocumentConfigurator.resolve(documentType: .termsOfService)
        viewController?.navigationController?.pushViewController(documentViewController, animated: true)
    }
}
