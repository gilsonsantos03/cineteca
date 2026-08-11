import UIKit

final class HomeConfigurator {
    static func resolve(
        repository: MovieRepositoryProtocol,
        genreRepository: GenreRepositoryProtocol,
        movieDetailsBuilder: MovieDetailsBuilding
    ) -> UIViewController {
        let presenter = HomePresenter()
        let interactor = HomeInteractor(
            presenter: presenter,
            repository: repository,
            genreRepository: genreRepository
        )
        let router = HomeRouter(movieDetailsBuilder: movieDetailsBuilder)
        let view = HomeView()
        let viewController = HomeViewController(customView: view, interactor: interactor, router: router)

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
