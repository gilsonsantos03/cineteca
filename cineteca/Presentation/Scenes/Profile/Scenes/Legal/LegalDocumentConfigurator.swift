import UIKit

final class LegalDocumentConfigurator {
    static func resolve(documentType: LegalDocumentType) -> UIViewController {
        let router = LegalDocumentRouter()
        let content = LegalDocumentContentBuilder.makeContent(for: documentType)
        let view = LegalDocumentView(content: content)
        let viewController = LegalDocumentViewController(
            customView: view,
            router: router
        )

        router.viewController = viewController
        return viewController
    }
}
