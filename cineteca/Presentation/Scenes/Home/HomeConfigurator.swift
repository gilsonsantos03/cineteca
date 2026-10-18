import UIKit

final class HomeConfigurator {
    static func resolve(
        repository: MovieRepositoryProtocol,
        genreRepository: GenreRepositoryProtocol,
        activityRepository: MovieActivityRepositoryProtocol,
        movieDetailsBuilder: MovieDetailsBuilding,
        movieCatalogBuilder: MovieCatalogBuilding
    ) -> UIViewController {
        let presenter = HomePresenter()
        let interactor = HomeInteractor(
            presenter: presenter,
            repository: repository,
            genreRepository: genreRepository,
            activityRepository: activityRepository
        )
        let router = HomeRouter(
            movieDetailsBuilder: movieDetailsBuilder,
            movieCatalogBuilder: movieCatalogBuilder
        )
        let view = HomeView()
        let viewController = HomeViewController(customView: view, interactor: interactor, router: router)

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
