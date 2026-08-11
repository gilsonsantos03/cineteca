import UIKit

final class MovieDetailsConfigurator {
    static func resolve(
        movieId: Int,
        repository: MovieRepositoryProtocol,
        movieDetailsBuilder: MovieDetailsBuilding
    ) -> UIViewController {
        let presenter = MovieDetailsPresenter()
        let interactor = MovieDetailsInteractor(presenter: presenter, repository: repository)
        let router = MovieDetailsRouter(movieDetailsBuilder: movieDetailsBuilder)
        let view = MovieDetailsView()
        let viewController = MovieDetailsViewController(
            movieId: movieId,
            customView: view,
            interactor: interactor,
            router: router
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
