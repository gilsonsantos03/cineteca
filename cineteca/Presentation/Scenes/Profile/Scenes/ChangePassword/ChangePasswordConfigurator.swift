import UIKit

final class ChangePasswordConfigurator {
    static func resolve(userRepository: UserRepositoryProtocol) -> UIViewController {
        let presenter = ChangePasswordPresenter()
        let interactor = ChangePasswordInteractor(
            presenter: presenter,
            userRepository: userRepository
        )
        let router = ChangePasswordRouter()
        let view = ChangePasswordView()
        let viewController = ChangePasswordViewController(
            customView: view,
            interactor: interactor,
            router: router
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
