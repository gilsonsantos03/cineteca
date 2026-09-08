import UIKit

final class ProfileConfigurator {
    static func resolve(
        userRepository: UserRepositoryProtocol,
        appearanceRepository: AppearanceRepositoryProtocol,
        languageRepository: LanguageRepositoryProtocol
    ) -> UIViewController {
        let presenter = ProfilePresenter()
        let interactor = ProfileInteractor(
            presenter: presenter,
            userRepository: userRepository
        )
        let router = ProfileRouter(
            userRepository: userRepository,
            appearanceRepository: appearanceRepository,
            languageRepository: languageRepository
        )
        let view = ProfileView()
        let viewController = ProfileViewController(
            customView: view,
            interactor: interactor,
            router: router
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
