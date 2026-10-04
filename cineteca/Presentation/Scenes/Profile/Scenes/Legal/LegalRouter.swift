import UIKit

protocol LegalRoutingLogic {
    func routeBack()
    func routeToPrivacyPolicy()
    func routeToTermsOfService()
}

final class LegalRouter {
    weak var viewController: UIViewController?
    private let legalDocumentBuilder: LegalDocumentBuilding

    init(legalDocumentBuilder: LegalDocumentBuilding) {
        self.legalDocumentBuilder = legalDocumentBuilder
    }
}

extension LegalRouter: LegalRoutingLogic {
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func routeToPrivacyPolicy() {
        let documentViewController = legalDocumentBuilder.makeLegalDocument(documentType: .privacyPolicy)
        viewController?.navigationController?.pushViewController(documentViewController, animated: true)
    }

    func routeToTermsOfService() {
        let documentViewController = legalDocumentBuilder.makeLegalDocument(documentType: .termsOfService)
        viewController?.navigationController?.pushViewController(documentViewController, animated: true)
    }
}
