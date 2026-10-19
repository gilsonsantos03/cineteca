import UIKit

final class AuthenticationConfigurator {
    static func resolve(
        authRepository: AuthRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        providers: [AuthenticationProviderProtocol],
        providerViewModels: [AuthenticationModels.ProviderViewModel]
    ) -> AuthenticationViewController {
        let presenter = AuthenticationPresenter()
        let interactor = AuthenticationInteractor(
            presenter: presenter,
            authRepository: authRepository,
            userRepository: userRepository,
            providers: providers
        )
        let router = AuthenticationRouter()
        let view = AuthenticationView(providers: providerViewModels)
        let viewController = AuthenticationViewController(
            customView: view,
            interactor: interactor,
            router: router
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
