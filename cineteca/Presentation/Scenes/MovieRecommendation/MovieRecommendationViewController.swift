import UIKit

protocol MovieRecommendationDisplayLogic: AnyObject {
    func displayLoading()
    func displayGenerate(viewModel: MovieRecommendationModels.Generate.ViewModel)
}

final class MovieRecommendationViewController: UIViewController {
    private let customView: MovieRecommendationView
    private let interactor: MovieRecommendationBusinessLogic
    private let router: MovieRecommendationRoutingLogic
    private let searchBuilder: SearchBuilding
    private let authGate: AuthenticationGateProtocol
    private var selectedMovies: [MovieRecommendationModels.SelectedMovieViewModel] = []
    private var selectionSlot = 0
    private var currentMode: MovieRecommendationMode = .moment("")
    private var currentResult: MovieRecommendationModels.Generate.ResultViewModel?

    init(
        customView: MovieRecommendationView,
        interactor: MovieRecommendationBusinessLogic,
        router: MovieRecommendationRoutingLogic,
        searchBuilder: SearchBuilding,
        authGate: AuthenticationGateProtocol
    ) {
        self.customView = customView
        self.interactor = interactor
        self.router = router
        self.searchBuilder = searchBuilder
        self.authGate = authGate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        customView.delegate = self
        customView.updateSelectedMovies(selectedMovies)
        if !authGate.isAuthenticated {
            authGate.requestAuthentication()
        }
    }
}

extension MovieRecommendationViewController: MovieRecommendationDisplayLogic {
    func displayLoading() {
        customView.displayLoading()
    }

    func displayGenerate(viewModel: MovieRecommendationModels.Generate.ViewModel) {
        switch viewModel {
        case let .content(result):
            currentResult = result
            customView.displayResult(result)
        case let .error(message):
            customView.displayError(message)
        }
    }

}

extension MovieRecommendationViewController: MovieRecommendationViewDelegate {
    func didRequestRecommendation(mode: MovieRecommendationMode) {
        guard authGate.isAuthenticated else {
            authGate.requestAuthentication()
            return
        }
        currentMode = mode
        interactor.generate(request: .init(mode: mode))
    }

    func didRequestBack() {
        router.routeBack()
    }

    func didRequestMovieSelection(at index: Int) {
        selectionSlot = index
        let delegate = self
        let search = searchBuilder.makeSearch(selectionBehavior: .selectMovie, selectionDelegate: delegate)
        let navigationController = UINavigationController(rootViewController: search)
        navigationController.modalPresentationStyle = .pageSheet
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(navigationController, animated: true)
    }

    func didRemoveMovie(at index: Int) {
        guard selectedMovies.indices.contains(index) else { return }
        selectedMovies.remove(at: index)
        customView.updateSelectedMovies(selectedMovies)
    }

    func didRequestNewRecommendation() {
        currentResult = nil
        currentMode = .moment("")
        selectedMovies.removeAll()
        selectionSlot = 0
        customView.resetForNewRecommendation()
    }

    func didSelectRecommendedMovie() {
        guard let resultID = currentResult?.movieID else { return }
        router.routeToMovieDetails(movieID: resultID)
    }

    func didRequestRetry() {
        guard authGate.isAuthenticated else {
            authGate.requestAuthentication()
            return
        }
        interactor.generate(request: .init(mode: currentMode))
    }
}

extension MovieRecommendationViewController: SearchSelectionDelegate {
    func didSelectMovie(movieId: Int, title: String, backdropURL: URL?) {
        if let existingIndex = selectedMovies.firstIndex(where: { $0.id == movieId }), existingIndex != selectionSlot {
            let alert = UIAlertController(
                title: Strings.MovieRecommendationScene.duplicateMovieTitle,
                message: Strings.MovieRecommendationScene.duplicateMovieMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: Strings.Common.ok, style: .default))
            present(alert, animated: true)
            return
        }
        let selected = MovieRecommendationModels.SelectedMovieViewModel(
            id: movieId,
            title: title,
            backdropURL: backdropURL
        )
        if selectedMovies.indices.contains(selectionSlot) {
            selectedMovies[selectionSlot] = selected
        } else if selectedMovies.count < 2 {
            selectedMovies.append(selected)
        }
        customView.updateSelectedMovies(selectedMovies)
    }
}
