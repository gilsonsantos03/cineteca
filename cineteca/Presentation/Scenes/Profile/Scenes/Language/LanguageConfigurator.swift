import UIKit

final class LanguageConfigurator {
    static func resolve(languageRepository: LanguageRepositoryProtocol) -> UIViewController {
        let presenter = LanguagePresenter()
        let interactor = LanguageInteractor(
            presenter: presenter,
            languageRepository: languageRepository
        )
        let router = LanguageRouter()
        let view = LanguageView()
        let viewController = LanguageViewController(
            customView: view,
            interactor: interactor,
            router: router
        )

        presenter.view = viewController
        router.viewController = viewController

        return viewController
    }
}
