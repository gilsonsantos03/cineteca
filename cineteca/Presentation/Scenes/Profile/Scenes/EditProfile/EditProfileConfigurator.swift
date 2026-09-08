import UIKit

final class EditProfileConfigurator {
    static func resolve(userRepository: UserRepositoryProtocol) -> UIViewController {
        let presenter = EditProfilePresenter()
        let interactor = EditProfileInteractor(
            presenter: presenter,
            userRepository: userRepository
        )
        let router = EditProfileRouter()
        let view = EditProfileView()
        let viewController = EditProfileViewController(
            customView: view,
            interactor: interactor,
            router: router
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
