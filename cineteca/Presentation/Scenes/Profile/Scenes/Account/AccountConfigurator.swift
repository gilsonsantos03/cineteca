import UIKit

final class AccountConfigurator {
    static func resolve(
        userRepository: UserRepositoryProtocol,
        authRepository: AuthRepositoryProtocol,
        authGate: AuthenticationGateProtocol
    ) -> UIViewController {
        let presenter = AccountPresenter()
        let interactor = AccountInteractor(
            presenter: presenter,
            userRepository: userRepository
        )
        let router = AccountRouter()
        let view = AccountView()
        let viewController = AccountViewController(
            customView: view,
            interactor: interactor,
            userRepository: userRepository,
            router: router,
            authRepository: authRepository,
            authGate: authGate
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
