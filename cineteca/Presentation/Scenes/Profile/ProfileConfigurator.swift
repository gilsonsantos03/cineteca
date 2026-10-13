import UIKit

final class ProfileConfigurator {
    static func resolve(
        userRepository: UserRepositoryProtocol,
        editProfileBuilder: EditProfileBuilding,
        myReviewsBuilder: MyReviewsBuilding,
        accountBuilder: AccountBuilding,
        appearanceBuilder: AppearanceBuilding,
        languageBuilder: LanguageBuilding,
        legalBuilder: LegalBuilding
    ) -> UIViewController {
        let presenter = ProfilePresenter()
        let interactor = ProfileInteractor(
            presenter: presenter,
            userRepository: userRepository
        )
        let router = ProfileRouter(
            editProfileBuilder: editProfileBuilder,
            myReviewsBuilder: myReviewsBuilder,
            accountBuilder: accountBuilder,
            appearanceBuilder: appearanceBuilder,
            languageBuilder: languageBuilder,
            legalBuilder: legalBuilder
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
