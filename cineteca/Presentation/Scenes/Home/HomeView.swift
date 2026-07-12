import UIKit
import Cartography

protocol HomeViewDelegate: AnyObject {
    func homeViewDidRequestRefresh(_ view: HomeView)
    func homeViewDidRequestRetry(_ view: HomeView)
    func didSelectGenreAt(_ index: Int)
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
    private lazy var errorStateView = HomeErrorStateView()

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
    }

    private func setupConstraints() {
        constrainLoadingSkeletonView()
        constrainHomeContentView()
        constrainErrorStateView()
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

    // MARK: - Public API

    func showLoading() {
        setState(.loading)
    }

    func showContent(viewModel: HomeModels.FetchContent.ViewModel) {
        homeContentView.configure(viewModel: viewModel)
        setState(.content)
    }

    func showError() {
        setState(.error)
    }

    func endRefreshing() {
        homeContentView.endRefreshing()
    }

    // MARK: - Helpers

    private func setState(_ state: State) {
        loadingSkeletonView.isHidden = state != .loading
        homeContentView.isHidden = state != .content
        errorStateView.isHidden = state != .error
    }
}

// MARK: - HomeContentViewDelegate

extension HomeView: HomeContentViewDelegate {
    func homeContentViewDidRequestRefresh(_ view: HomeContentView) {
        delegate?.homeViewDidRequestRefresh(self)
    }

    func homeContentView(_ view: HomeContentView, didSelectGenreAt index: Int) {
        delegate?.didSelectGenreAt(index)
    }
}

// MARK: - HomeErrorStateViewDelegate

extension HomeView: HomeErrorStateViewDelegate {
    func homeErrorStateViewDidRequestRetry(_ view: HomeErrorStateView) {
        delegate?.homeViewDidRequestRetry(self)
    }
}
