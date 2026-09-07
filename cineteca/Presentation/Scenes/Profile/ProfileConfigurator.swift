import UIKit

final class ProfileConfigurator {
    static func resolve(userRepository: UserRepositoryProtocol) -> UIViewController {
        let presenter = ProfilePresenter()
        let interactor = ProfileInteractor(
            presenter: presenter,
            userRepository: userRepository
        )
        let router = ProfileRouter()
        let view = ProfileView()
        let viewController = ProfileViewController(customView: view, interactor: interactor)

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
