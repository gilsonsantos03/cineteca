import UIKit

final class StatsConfigurator {
    static func resolve(statsRepository: StatsRepositoryProtocol) -> UIViewController {
        let presenter = StatsPresenter()
        let interactor = StatsInteractor(
            presenter: presenter,
            statsRepository: statsRepository
        )
        let view = StatsView()
        let viewController = StatsViewController(
            customView: view,
            interactor: interactor
        )

        presenter.view = viewController

        return viewController
    }
}
