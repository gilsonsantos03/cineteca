import UIKit

@MainActor
final class ListsConfigurator {
    static func resolve(
        activityRepository: MovieActivityRepositoryProtocol,
        movieDetailsBuilder: MovieDetailsBuilding,
        authGate: AuthenticationGateProtocol
    ) -> UIViewController {
        let presenter = ListsPresenter()
        let interactor = ListsInteractor(
            presenter: presenter,
            activityRepository: activityRepository
        )
        let router = ListsRouter(movieDetailsBuilder: movieDetailsBuilder)
        let view = ListsView()
        let viewController = ListsViewController(
            customView: view,
            interactor: interactor,
            router: router,
            authGate: authGate
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
