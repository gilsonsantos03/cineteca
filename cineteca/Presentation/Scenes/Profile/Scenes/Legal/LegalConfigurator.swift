import UIKit

final class LegalConfigurator {
    static func resolve() -> UIViewController {
        let presenter = LegalPresenter()
        let interactor = LegalInteractor(presenter: presenter)
        let router = LegalRouter()
        let view = LegalView()
        let viewController = LegalViewController(
            customView: view,
            interactor: interactor,
            router: router
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
