import UIKit

@MainActor
final class ProfileConfigurator {
    static func resolve(
        userRepository: UserRepositoryProtocol,
        movieDetailsBuilder: MovieDetailsBuilding,
        editProfileBuilder: EditProfileBuilding,
        myReviewsBuilder: MyReviewsBuilding,
        accountBuilder: AccountBuilding,
        appearanceBuilder: AppearanceBuilding,
        languageBuilder: LanguageBuilding,
        legalBuilder: LegalBuilding,
        authGate: AuthenticationGateProtocol,
        authRepository: AuthRepositoryProtocol
    ) -> UIViewController {
        let presenter = ProfilePresenter()
        let interactor = ProfileInteractor(
            presenter: presenter,
            userRepository: userRepository
        )
        let router = ProfileRouter(
            movieDetailsBuilder: movieDetailsBuilder,
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
            router: router,
            authGate: authGate,
            authRepository: authRepository
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
