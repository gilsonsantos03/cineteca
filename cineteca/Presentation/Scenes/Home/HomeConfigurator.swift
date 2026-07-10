import UIKit

final class HomeConfigurator {
    static func resolve(repository: MovieRepositoryProtocol) -> UIViewController {
        let presenter = HomePresenter()
        let interactor = HomeInteractor(presenter: presenter, repository: repository)
        let router = HomeRouter()
        let view = HomeView()
        let viewController = HomeViewController(customView: view, interactor: interactor, router: router)

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
