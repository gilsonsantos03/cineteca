import UIKit

final class AppearanceConfigurator {
    static func resolve(appearanceRepository: AppearanceRepositoryProtocol) -> UIViewController {
        let presenter = AppearancePresenter()
        let interactor = AppearanceInteractor(
            presenter: presenter,
            appearanceRepository: appearanceRepository
        )
        let router = AppearanceRouter()
        let view = AppearanceView()
        let viewController = AppearanceViewController(
            customView: view,
            interactor: interactor,
            router: router
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
