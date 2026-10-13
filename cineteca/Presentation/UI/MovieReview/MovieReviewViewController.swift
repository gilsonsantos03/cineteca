import UIKit

// MARK: - Movie Review View Controller

final class MovieReviewViewController: UIViewController {
    struct Configuration {
        let movieTitle: String
        let metadata: String
        let posterURL: URL?
        let currentRating: Double?
        let currentReviewText: String?
    }

    // MARK: Properties

    private let customView: MovieReviewView
    weak var delegate: MovieReviewViewControllerDelegate?

    // MARK: Initialization

    init(configuration: Configuration) {
        self.customView = MovieReviewView(
            movieTitle: configuration.movieTitle,
            metadata: configuration.metadata,
            posterURL: configuration.posterURL,
            currentRating: configuration.currentRating,
            currentReviewText: configuration.currentReviewText
        )
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Lifecycle

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.delegate = self
    }
}

// MARK: - Delegate

protocol MovieReviewViewControllerDelegate: AnyObject {
    func movieReviewViewControllerDidRequestClose(_ viewController: MovieReviewViewController)
    func movieReviewViewController(
        _ viewController: MovieReviewViewController,
        didSubmitRating rating: Double,
        reviewText: String?
    )
}

// MARK: - MovieReviewViewDelegate

extension MovieReviewViewController: MovieReviewViewDelegate {
    func movieReviewViewDidRequestClose(_ view: MovieReviewView) {
        delegate?.movieReviewViewControllerDidRequestClose(self)
    }

    func movieReviewView(
        _ view: MovieReviewView,
        didSubmit rating: Double,
        reviewText: String?
    ) {
        delegate?.movieReviewViewController(
            self,
            didSubmitRating: rating,
            reviewText: reviewText
        )
    }
}
