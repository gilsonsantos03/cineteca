import UIKit

@MainActor
final class MovieDetailsConfigurator {
    static func resolve(
        movieId: Int,
        repository: MovieRepositoryProtocol,
        activityRepository: MovieActivityRepositoryProtocol,
        movieDetailsBuilder: MovieDetailsBuilding,
        movieReviewSheetFactory: MovieReviewSheetBuilding,
        authGate: AuthenticationGateProtocol
    ) -> UIViewController {
        let presenter = MovieDetailsPresenter()
        let interactor = MovieDetailsInteractor(
            presenter: presenter,
            repository: repository,
            activityRepository: activityRepository
        )
        let router = MovieDetailsRouter(movieDetailsBuilder: movieDetailsBuilder)
        let view = MovieDetailsView()
        let viewController = MovieDetailsViewController(
            movieId: movieId,
            customView: view,
            interactor: interactor,
            router: router,
            movieReviewSheetFactory: movieReviewSheetFactory,
            authGate: authGate
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
