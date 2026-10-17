import UIKit

protocol MyReviewsDisplayLogic: AnyObject {
    func displayFetchReviews(viewModel: MyReviewsModels.FetchReviews.ViewModel)
    func displayUpdateReview(viewModel: MyReviewsModels.UpdateReview.ViewModel)
    func displayLoading()
}

final class MyReviewsViewController: UIViewController {
    private let customView: MyReviewsView
    private let interactor: MyReviewsBusinessLogic
    private let movieReviewSheetFactory: MovieReviewSheetBuilding
    private var reviewController: MovieReviewViewController?
    private var selectedReview: MyReviewsModels.ReviewCardViewModel?

    init(
        customView: MyReviewsView,
        interactor: MyReviewsBusinessLogic,
        movieReviewSheetFactory: MovieReviewSheetBuilding
    ) {
        self.customView = customView
        self.interactor = interactor
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor.fetchReviews(request: .init())
    }
}

extension MyReviewsViewController: MyReviewsDisplayLogic {
    func displayFetchReviews(viewModel: MyReviewsModels.FetchReviews.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        case .error:
            customView.showError()
        }
    }

    func displayUpdateReview(viewModel: MyReviewsModels.UpdateReview.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
            reviewController?.dismiss(animated: true)
            reviewController = nil
            selectedReview = nil
        case .error:
            let alert = UIAlertController(
                title: Strings.MyReviewsScene.updateErrorTitle,
                message: Strings.MyReviewsScene.updateErrorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: Strings.MyReviewsScene.okButton, style: .default))
            present(alert, animated: true)
        }
    }

    func displayLoading() {
        customView.showLoading()
    }
}

extension MyReviewsViewController: MyReviewsViewDelegate {
    func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    func didSelectReview(_ review: MyReviewsModels.ReviewCardViewModel) {
        selectedReview = review
        reviewController = movieReviewSheetFactory.present(
            from: self,
            configuration: .init(
                movieTitle: review.title,
                metadata: review.metadata,
                posterURL: review.posterURL,
                currentRating: review.rating,
                currentReviewText: review.reviewText
            ),
            delegate: self
        )
    }
}

extension MyReviewsViewController: MovieReviewViewControllerDelegate {
    func didRequestClose() {
        dismiss(animated: true)
        reviewController = nil
        selectedReview = nil
    }

    func didSubmitRating(_ rating: Double, reviewText: String?) {
        guard let selectedReview else { return }
        let metadata = MovieActivityMetadata(
            movieId: selectedReview.movieId,
            title: selectedReview.title,
            posterURL: selectedReview.posterURL,
            backdropURL: nil,
            runtimeMinutes: nil,
            releaseYear: selectedReview.releaseYear,
            genres: [],
            directorNames: selectedReview.directorName.map { [$0] } ?? [],
            actorNames: []
        )
        interactor.updateReview(
            request: .init(
                metadata: metadata,
                rating: rating,
                reviewText: reviewText
            )
        )
    }
}
