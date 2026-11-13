import UIKit
import Cartography

protocol HomeViewDelegate: AnyObject {
    func didTapMovieRecommendation()
    func didRequestRefresh()
    func didRequestRetry()
    func didSelectGenre(at index: Int)
    func didRequestWatchTrailer(movieId: Int)
    func didTapWatchlist(movieId: Int, isInWatchlist: Bool)
    func didSelectMovie(id movieId: Int)
    func didTapSeeAll(category: MovieCollectionCategory, title: String)
}

final class HomeView: UIView {

    // MARK: - Properties

    weak var delegate: HomeViewDelegate?

    // MARK: - State

    private enum State {
        case loading
        case content
        case error
    }

    // MARK: - UI Components

    private lazy var loadingSkeletonView = HomeSkeletonView()
    private lazy var homeContentView = HomeContentView()
    private lazy var errorStateView = ErrorStateView()
    private lazy var recommendationButton: MovieRecommendationFloatingButton = {
        let button = MovieRecommendationFloatingButton()
        button.actionDelegate = self
        return button
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
        homeContentView.delegate = self
        errorStateView.delegate = self
        setupSubviews()
        setupConstraints()
        setState(.loading)
    }

    private func setupSubviews() {
        addSubview(homeContentView)
        addSubview(errorStateView)
        addSubview(loadingSkeletonView)
        addSubview(recommendationButton)
    }

    private func setupConstraints() {
        constrainLoadingSkeletonView()
        constrainHomeContentView()
        constrainErrorStateView()
        constrainRecommendationButton()
    }

    private func constrainLoadingSkeletonView() {
        constrain(loadingSkeletonView, self) { view, superview in
            view.edges == superview.edges
        }
    }

    private func constrainHomeContentView() {
        constrain(homeContentView, self) { view, superview in
            view.edges == superview.edges
        }
    }

    private func constrainErrorStateView() {
        constrain(errorStateView, self) { view, superview in
            view.edges == superview.edges
        }
    }

    private func constrainRecommendationButton() {
        constrain(recommendationButton, self) { button, superview in
            button.trailing == superview.trailing - 20
            button.bottom == superview.safeAreaLayoutGuide.bottom - 20
            button.height == 50
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        bringSubviewToFront(recommendationButton)
    }

    // MARK: - Public API

    func showLoading() {
        setState(.loading)
    }

    func showContent(content: HomeModels.FetchContent.ViewModel.Content) {
        homeContentView.configure(content: content)
        setState(.content)
    }

    func showError() {
        setState(.error)
    }

    func endRefreshing() {
        homeContentView.endRefreshing()
    }

    func updateWatchlist(isInWatchlist: Bool) {
        homeContentView.updateWatchlist(isInWatchlist: isInWatchlist)
    }

    // MARK: - Helpers

    private func setState(_ state: State) {
        loadingSkeletonView.isHidden = state != .loading
        homeContentView.isHidden = state != .content
        errorStateView.isHidden = state != .error
        recommendationButton.isHidden = state == .loading
        bringSubviewToFront(recommendationButton)
    }
}

extension HomeView: MovieRecommendationFloatingButtonDelegate {
    func didTapMovieRecommendation() {
        delegate?.didTapMovieRecommendation()
    }
}

// MARK: - HomeContentViewDelegate

extension HomeView: HomeContentViewDelegate {
    func didRequestRefresh() {
        delegate?.didRequestRefresh()
    }

    func didSelectGenre(at index: Int) {
        delegate?.didSelectGenre(at: index)
    }

    func didRequestWatchTrailer(movieId: Int) {
        delegate?.didRequestWatchTrailer(movieId: movieId)
    }

    func didTapWatchlist(movieId: Int, isInWatchlist: Bool) {
        delegate?.didTapWatchlist(movieId: movieId, isInWatchlist: isInWatchlist)
    }

    func didSelectMovie(id movieId: Int) {
        delegate?.didSelectMovie(id: movieId)
    }

    func didTapSeeAll(category: MovieCollectionCategory, title: String) {
        delegate?.didTapSeeAll(category: category, title: title)
    }
}

// MARK: - ErrorStateViewDelegate

extension HomeView: ErrorStateViewDelegate {
    func didRequestRetry() {
        delegate?.didRequestRetry()
    }
}
