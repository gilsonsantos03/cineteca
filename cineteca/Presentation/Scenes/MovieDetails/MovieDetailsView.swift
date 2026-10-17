import UIKit
import Cartography

protocol MovieDetailsViewDelegate: AnyObject {
    func didRequestRetry()
    func didRequestBack()
    func didRequestTrailer(for movieId: Int)
    func didSelectSimilarMovie(id movieId: Int)
    func didRequestRate()
    func didRequestFavorite(isFavorite: Bool)
    func didRequestWatchlist(isInWatchlist: Bool)
}

final class MovieDetailsView: UIView {

    // MARK: - Properties

    weak var delegate: MovieDetailsViewDelegate?
    private var movieId: Int?

    // MARK: - UI Components

    private lazy var headerView = MovieDetailsHeaderView()
    private lazy var actionsView = MovieDetailsActionsView()
    private lazy var activityHintLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        label.text = Strings.MovieDetailsScene.Favorite.disabledHint
        label.isHidden = true
        return label
    }()
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
            activityHintLabel,
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
        switch viewModel {
        case let .content(content):
            showContent(content)
        case let .error(error):
            showError(error)
        }
    }

    private func showContent(_ viewModel: MovieDetailsModels.FetchDetails.ViewModel.Content) {
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
        actionsView.configure(activity: viewModel.activity)
        activityHintLabel.isHidden = viewModel.activity.canFavorite
        providersView.configure(viewModel.watchProviders)
        overviewView.configure(text: viewModel.overview)
        castView.configure(viewModel.cast)
        crewView.configure(viewModel.crew)
        similarMoviesView.configure(viewModel.similarMovies)
        loader.stopAnimating()
        errorView.isHidden = true
        scrollView.isHidden = false
    }

    func showActivity(viewModel: MovieDetailsModels.ActivityViewModel) {
        actionsView.configure(activity: viewModel)
        activityHintLabel.isHidden = viewModel.canFavorite
    }

    private func showError(_ viewModel: MovieDetailsModels.FetchDetails.ViewModel.ErrorViewModel) {
        errorView.configure(viewModel: viewModel)
        loader.stopAnimating()
        scrollView.isHidden = true
        errorView.isHidden = false
    }

    // MARK: - Actions

    private func requestTrailer() {
        guard let movieId else { return }
        delegate?.didRequestTrailer(for: movieId)
    }

    private func selectSimilarMovie(_ movieId: Int) {
        delegate?.didSelectSimilarMovie(id: movieId)
    }
}

// MARK: - MovieDetailsHeaderViewDelegate

extension MovieDetailsView: MovieDetailsHeaderViewDelegate {
    func didTapBack() {
        delegate?.didRequestBack()
    }
}

// MARK: - MovieDetailsActionsViewDelegate

extension MovieDetailsView: MovieDetailsActionsViewDelegate {
    func didTapRate() {
        delegate?.didRequestRate()
    }

    func didTapFavorite() {
        delegate?.didRequestFavorite(isFavorite: !actionsView.isFavoriteSelected)
    }

    func didTapWatchlist() {
        delegate?.didRequestWatchlist(isInWatchlist: !actionsView.isWatchlistSelected)
    }
}

// MARK: - WatchTrailerButtonDelegate

extension MovieDetailsView: WatchTrailerButtonDelegate {
    func didTap() {
        requestTrailer()
    }
}

// MARK: - MovieDetailsSimilarMoviesViewDelegate

extension MovieDetailsView: MovieDetailsSimilarMoviesViewDelegate {
    func didSelectMovie(id movieId: Int) {
        selectSimilarMovie(movieId)
    }
}

// MARK: - MovieDetailsErrorViewDelegate

extension MovieDetailsView: MovieDetailsErrorViewDelegate {
    func didRequestRetry() {
        delegate?.didRequestRetry()
    }
}
