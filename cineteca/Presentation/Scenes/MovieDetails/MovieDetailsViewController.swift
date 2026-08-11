import UIKit

final class MovieDetailsViewController: UIViewController {
    private let movieId: Int
    private let customView: MovieDetailsView
    private let interactor: MovieDetailsBusinessLogic
    private let router: MovieDetailsRoutingLogic

    init(
        movieId: Int,
        customView: MovieDetailsView,
        interactor: MovieDetailsBusinessLogic,
        router: MovieDetailsRoutingLogic
    ) {
        self.movieId = movieId
        self.customView = customView
        self.interactor = interactor
        self.router = router
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
        interactor.fetchDetails(request: .init(movieId: movieId))
    }
}

// MARK: - MovieDetailsDisplayLogic

extension MovieDetailsViewController: MovieDetailsDisplayLogic {
    func displayLoading() {
        customView.showLoading()
    }

    func displayDetails(viewModel: MovieDetailsModels.FetchDetails.ViewModel) {
        customView.showDetails(viewModel: viewModel)
    }

    func displayError(viewModel: MovieDetailsModels.ErrorState.ViewModel) {
        customView.showError(viewModel: viewModel)
    }

    func displayWatchTrailer(viewModel: MovieDetailsModels.WatchTrailer.ViewModel) {
        switch viewModel {
        case let .success(youtubeKey):
            router.routeToTrailer(youtubeKey: youtubeKey)
        case let .unavailable(title, message):
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Strings.MovieDetailsScene.TrailerUnavailable.okButton, style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - MovieDetailsViewDelegate

extension MovieDetailsViewController: MovieDetailsViewDelegate {
    func movieDetailsViewDidRequestRetry(_ view: MovieDetailsView) {
        interactor.fetchDetails(request: .init(movieId: movieId))
    }

    func movieDetailsViewDidRequestBack(_ view: MovieDetailsView) {
        router.routeBack()
    }

    func movieDetailsView(_ view: MovieDetailsView, didTapTrailerFor movieId: Int) {
        interactor.watchTrailer(request: .init(movieId: movieId))
    }

    func movieDetailsView(_ view: MovieDetailsView, didSelectSimilarMovie movieId: Int) {
        router.routeToMovieDetails(movieId: movieId)
    }
}
