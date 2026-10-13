import UIKit

final class MyReviewsConfigurator {
    static func resolve(
        userRepository: UserRepositoryProtocol,
        activityRepository: MovieActivityRepositoryProtocol,
        movieReviewSheetFactory: MovieReviewSheetBuilding
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
            movieReviewSheetFactory: movieReviewSheetFactory
        )

        presenter.view = viewController
        return viewController
    }
}
