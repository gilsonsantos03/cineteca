import UIKit

@MainActor
final class SearchConfigurator {
    static func resolve(
        repository: MovieRepositoryProtocol,
        genreRepository: GenreRepositoryProtocol,
        movieDetailsBuilder: MovieDetailsBuilding,
        selectionBehavior: SearchModels.SelectionBehavior = .openDetails,
        selectionDelegate: SearchSelectionDelegate? = nil
    ) -> UIViewController {
        let presenter = SearchPresenter()
        let interactor = SearchInteractor(
            presenter: presenter,
            repository: repository,
            genreRepository: genreRepository
        )
        let router = SearchRouter(movieDetailsBuilder: movieDetailsBuilder)
        let view = SearchView()
        let viewController = SearchViewController(
            customView: view,
            interactor: interactor,
            router: router,
            selectionBehavior: selectionBehavior
        )

        viewController.selectionDelegate = selectionDelegate
        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
