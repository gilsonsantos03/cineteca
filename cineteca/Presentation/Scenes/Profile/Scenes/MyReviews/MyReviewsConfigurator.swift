import UIKit

final class MyReviewsConfigurator {
    static func resolve(
        userRepository: UserRepositoryProtocol,
        activityRepository: MovieActivityRepositoryProtocol,
        movieReviewSheetFactory: MovieReviewSheetBuilding,
        authGate: AuthenticationGateProtocol
    ) -> UIViewController {
        let presenter = MyReviewsPresenter()
        let interactor = MyReviewsInteractor(
            presenter: presenter,
            userRepository: userRepository,
            activityRepository: activityRepository
        )
        let view = MyReviewsView()
        let viewController = MyReviewsViewController(
            customView: view,
            interactor: interactor,
            movieReviewSheetFactory: movieReviewSheetFactory,
            authGate: authGate
        )

        presenter.view = viewController
        return viewController
    }
}
