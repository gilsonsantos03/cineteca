import UIKit

@MainActor
final class MovieRecommendationConfigurator {
    static func resolve(
        recommendationRepository: MovieRecommendationRepositoryProtocol,
        movieRepository: MovieRepositoryProtocol,
        searchBuilder: SearchBuilding,
        movieDetailsBuilder: MovieDetailsBuilding,
        authGate: AuthenticationGateProtocol
    ) -> UIViewController {
        let presenter = MovieRecommendationPresenter()
        let interactor = MovieRecommendationInteractor(
            presenter: presenter,
            recommendationRepository: recommendationRepository,
            movieRepository: movieRepository
        )
        let router = MovieRecommendationRouter(movieDetailsBuilder: movieDetailsBuilder)
        let view = MovieRecommendationView()
        let viewController = MovieRecommendationViewController(
            customView: view,
            interactor: interactor,
            router: router,
            searchBuilder: searchBuilder,
            authGate: authGate
        )
        presenter.view = viewController
        router.viewController = viewController
        return viewController
    }
}
