import UIKit

protocol MovieDetailsDisplayLogic: AnyObject {
    func displayLoading()
    func displayDetails(viewModel: MovieDetailsModels.FetchDetails.ViewModel)
    func displayError(viewModel: MovieDetailsModels.ErrorState.ViewModel)
    func displayWatchTrailer(viewModel: MovieDetailsModels.WatchTrailer.ViewModel)
    func displayReview(viewModel: MovieDetailsModels.FetchReview.ViewModel)
    func displayActivity(viewModel: MovieDetailsModels.ActivityViewModel)
    func displayActivityError()
}

final class MovieDetailsViewController: UIViewController {
    private struct ReviewContext {
        let title: String
        let metadata: String
        let posterURL: URL?
        var rating: Double?
        var reviewText: String?
    }

    private let movieId: Int
    private let customView: MovieDetailsView
    private let interactor: MovieDetailsBusinessLogic
    private let router: MovieDetailsRoutingLogic
    private let movieReviewSheetFactory: MovieReviewSheetBuilding
    private var reviewContext: ReviewContext?

    init(
        movieId: Int,
        customView: MovieDetailsView,
        interactor: MovieDetailsBusinessLogic,
        router: MovieDetailsRoutingLogic,
        movieReviewSheetFactory: MovieReviewSheetBuilding
    ) {
        self.movieId = movieId
        self.customView = customView
        self.interactor = interactor
        self.router = router
        self.movieReviewSheetFactory = movieReviewSheetFactory
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
        reviewContext = ReviewContext(
            title: viewModel.title,
            metadata: viewModel.metadata,
            posterURL: viewModel.posterURL,
            rating: viewModel.activity.rating,
            reviewText: nil
        )
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

    func displayReview(viewModel: MovieDetailsModels.FetchReview.ViewModel) {
        reviewContext?.reviewText = viewModel.reviewText
        presentReviewForm()
    }

    func displayActivity(viewModel: MovieDetailsModels.ActivityViewModel) {
        reviewContext?.rating = viewModel.rating
        customView.showActivity(viewModel: viewModel)
    }

    func displayActivityError() {
        let alert = UIAlertController(
            title: Strings.MovieDetailsScene.ActivityError.title,
            message: Strings.MovieDetailsScene.ActivityError.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.MovieDetailsScene.ActivityError.okButton, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - MovieDetailsViewDelegate

extension MovieDetailsViewController: MovieDetailsViewDelegate {
    func didRequestRetry() {
        interactor.fetchDetails(request: .init(movieId: movieId))
    }

    func didRequestBack() {
        router.routeBack()
    }

    func didRequestTrailer(for movieId: Int) {
        interactor.watchTrailer(request: .init(movieId: movieId))
    }

    func didSelectSimilarMovie(id movieId: Int) {
        router.routeToMovieDetails(movieId: movieId)
    }

    func didRequestRate() {
        interactor.fetchReview(request: .init(movieId: movieId))
    }

    func didRequestFavorite(isFavorite: Bool) {
        interactor.updateActivity(
            request: .init(
                movieId: movieId,
                action: .favorite(isFavorite)
            )
        )
    }

    func didRequestWatchlist(isInWatchlist: Bool) {
        interactor.updateActivity(
            request: .init(
                movieId: movieId,
                action: .watchlist(isInWatchlist)
            )
        )
    }

    private func presentReviewForm() {
        guard let reviewContext else { return }
        movieReviewSheetFactory.present(
            from: self,
            configuration: .init(
            movieTitle: reviewContext.title,
            metadata: reviewContext.metadata,
            posterURL: reviewContext.posterURL,
            currentRating: reviewContext.rating,
            currentReviewText: reviewContext.reviewText
            ),
            delegate: self
        )
    }
}

extension MovieDetailsViewController: MovieReviewViewControllerDelegate {
    func movieReviewViewControllerDidRequestClose(_ viewController: MovieReviewViewController) {
        viewController.dismiss(animated: true)
    }

    func movieReviewViewController(
        _ viewController: MovieReviewViewController,
        didSubmitRating rating: Double,
        reviewText: String?
    ) {
        reviewContext?.rating = rating
        reviewContext?.reviewText = reviewText
        interactor.updateActivity(
            request: .init(
                movieId: movieId,
                action: .rate(rating: rating, reviewText: reviewText)
            )
        )
        viewController.dismiss(animated: true)
    }
}
