import UIKit

@MainActor
final class EditProfileConfigurator {
    static func resolve(
        userRepository: UserRepositoryProtocol,
        searchBuilder: SearchBuilding,
        authGate: AuthenticationGateProtocol
    ) -> UIViewController {
        let presenter = EditProfilePresenter()
        let interactor = EditProfileInteractor(
            presenter: presenter,
            userRepository: userRepository
        )
        let router = EditProfileRouter(searchBuilder: searchBuilder)
        let view = EditProfileView()
        let viewController = EditProfileViewController(
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
