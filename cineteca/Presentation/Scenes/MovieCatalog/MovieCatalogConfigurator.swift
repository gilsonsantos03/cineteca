import UIKit

final class MovieCatalogConfigurator {
    static func resolve(
        category: MovieCollectionCategory,
        title: String,
        repository: MovieRepositoryProtocol,
        genreRepository: GenreRepositoryProtocol,
        movieDetailsBuilder: MovieDetailsBuilding
    ) -> UIViewController {
        let presenter = MovieCatalogPresenter()
        let interactor = MovieCatalogInteractor(
            presenter: presenter,
            repository: repository,
            genreRepository: genreRepository,
            category: category
        )
        let router = MovieCatalogRouter(movieDetailsBuilder: movieDetailsBuilder)
        let view = MovieCatalogView(title: title)
        let viewController = MovieCatalogViewController(
            customView: view,
            interactor: interactor,
            router: router
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
