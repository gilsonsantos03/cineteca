import UIKit
import Cartography

protocol MovieDetailsViewDelegate: AnyObject {
    func movieDetailsViewDidRequestRetry(_ view: MovieDetailsView)
    func movieDetailsViewDidRequestBack(_ view: MovieDetailsView)
    func movieDetailsView(_ view: MovieDetailsView, didTapTrailerFor movieId: Int)
    func movieDetailsView(_ view: MovieDetailsView, didSelectSimilarMovie movieId: Int)
}

final class MovieDetailsView: UIView {

    // MARK: - Properties

    weak var delegate: MovieDetailsViewDelegate?
    private var movieId: Int?

    // MARK: - UI Components

    private lazy var headerView = MovieDetailsHeaderView()
    private lazy var actionsView = MovieDetailsActionsView()
    private lazy var ratingView = MovieDetailsRatingView()
    private lazy var providersView = MovieDetailsProvidersView()
    private lazy var overviewView = MovieDetailsOverviewView()
    private lazy var castView = MovieDetailsCastView()
    private lazy var crewView = MovieDetailsCrewView()
    private lazy var watchTrailerButton: WatchTrailerButton = {
        let button = WatchTrailerButton(style: .detailsCard)
        button.delegate = self
        return button
    }()
    private lazy var similarMoviesView = MovieDetailsSimilarMoviesView()
    private lazy var errorView = MovieDetailsErrorView()

    private lazy var loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .accentYellow
        return indicator
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private lazy var detailsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            actionsView,
            ratingView,
            providersView,
            overviewView,
            castView,
            crewView,
            watchTrailerButton,
            similarMoviesView
        ])
        stack.axis = .vertical
        stack.spacing = 26
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 36, right: 20)
        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        setupDelegates()
        setupSubviews()
        setupConstraints()
        errorView.isHidden = true
    }

    private func setupDelegates() {
        headerView.delegate = self
        actionsView.delegate = self
        watchTrailerButton.delegate = self
        similarMoviesView.delegate = self
        errorView.delegate = self
    }

    private func setupSubviews() {
        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(detailsStack)
        scrollView.addSubview(contentStack)
        addSubview(scrollView)
        addSubview(loader)
        addSubview(errorView)
    }

    private func setupConstraints() {
        constrainScrollView()
        constrainContentStack()
        constrainHeaderView()
        constrainLoader()
        constrainErrorView()
    }

    private func constrainScrollView() {
        constrain(scrollView, self) { scrollView, superview in
            scrollView.edges == superview.edges
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView) { stack, scrollView in
            stack.edges == scrollView.edges
            stack.width == scrollView.width
        }
    }

    private func constrainHeaderView() {
        constrain(headerView) { header in
            header.height == 370
        }
    }

    private func constrainLoader() {
        constrain(loader, self) { loader, superview in
            loader.center == superview.center
        }
    }

    private func constrainErrorView() {
        constrain(errorView, self) { errorView, superview in
            errorView.center == superview.center
            errorView.left == superview.left + 32
            errorView.right == superview.right - 32
        }
    }

    // MARK: - Public API

    func showLoading() {
        scrollView.isHidden = true
        errorView.isHidden = true
        loader.startAnimating()
    }

    func showDetails(viewModel: MovieDetailsModels.FetchDetails.ViewModel) {
        movieId = viewModel.movieId
        headerView.configure(
            title: viewModel.title,
            metadata: viewModel.metadata,
            certification: viewModel.certification,
            genres: viewModel.genres,
            posterURL: viewModel.posterURL,
            backdropURL: viewModel.backdropURL
        )
        ratingView.configure(rating: viewModel.rating)
        providersView.configure(viewModel.watchProviders)
        overviewView.configure(text: viewModel.overview)
        castView.configure(viewModel.cast)
        crewView.configure(viewModel.crew)
        similarMoviesView.configure(viewModel.similarMovies)
        loader.stopAnimating()
        errorView.isHidden = true
        scrollView.isHidden = false
    }

    func showError(viewModel: MovieDetailsModels.ErrorState.ViewModel) {
        errorView.configure(title: viewModel.title, message: viewModel.message)
        loader.stopAnimating()
        scrollView.isHidden = true
        errorView.isHidden = false
    }

    // MARK: - Actions

    private func requestTrailer() {
        guard let movieId else { return }
        delegate?.movieDetailsView(self, didTapTrailerFor: movieId)
    }

    private func selectSimilarMovie(_ movieId: Int) {
        delegate?.movieDetailsView(self, didSelectSimilarMovie: movieId)
    }
}

// MARK: - MovieDetailsHeaderViewDelegate

extension MovieDetailsView: MovieDetailsHeaderViewDelegate {
    func movieDetailsHeaderDidTapBack() {
        delegate?.movieDetailsViewDidRequestBack(self)
    }
}

// MARK: - MovieDetailsActionsViewDelegate

extension MovieDetailsView: MovieDetailsActionsViewDelegate {
    func movieDetailsActionsView(_ view: MovieDetailsActionsView, didTapRate button: UIButton) {}

    func movieDetailsActionsView(_ view: MovieDetailsActionsView, didTapFavorite button: UIButton) {}

    func movieDetailsActionsView(_ view: MovieDetailsActionsView, didTapWatchlist button: UIButton) {}
}

// MARK: - WatchTrailerButtonDelegate

extension MovieDetailsView: WatchTrailerButtonDelegate {
    func watchTrailerButtonDidTap(_ button: WatchTrailerButton) {
        requestTrailer()
    }
}

// MARK: - MovieDetailsSimilarMoviesViewDelegate

extension MovieDetailsView: MovieDetailsSimilarMoviesViewDelegate {
    func movieDetailsSimilarMoviesView(_ view: MovieDetailsSimilarMoviesView, didSelectMovie movieId: Int) {
        selectSimilarMovie(movieId)
    }
}

// MARK: - MovieDetailsErrorViewDelegate

extension MovieDetailsView: MovieDetailsErrorViewDelegate {
    func movieDetailsErrorViewDidRequestRetry(_ view: MovieDetailsErrorView) {
        delegate?.movieDetailsViewDidRequestRetry(self)
    }
}
