import UIKit

final class AccountConfigurator {
    static func resolve(
        userRepository: UserRepositoryProtocol,
        changePasswordBuilder: ChangePasswordBuilding
    ) -> UIViewController {
        let presenter = AccountPresenter()
        let interactor = AccountInteractor(
            presenter: presenter,
            userRepository: userRepository
        )
        let router = AccountRouter(changePasswordBuilder: changePasswordBuilder)
        let view = AccountView()
        let viewController = AccountViewController(
            customView: view,
            interactor: interactor,
            router: router
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
