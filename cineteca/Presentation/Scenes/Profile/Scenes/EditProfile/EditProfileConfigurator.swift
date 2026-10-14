import UIKit

final class EditProfileConfigurator {
    static func resolve(
        userRepository: UserRepositoryProtocol,
        searchBuilder: SearchBuilding
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
            router: router
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
