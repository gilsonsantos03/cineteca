import UIKit
import Cartography

final class HomeView: UIView {

    // MARK: - State

    private enum State {
        case loading
        case content
        case error
    }

    // MARK: - Public API

    var onRefresh: (() -> Void)? {
        didSet { homeContentView.onRefresh = onRefresh }
    }

    var onRetry: (() -> Void)? {
        didSet { errorStateView.onRetry = onRetry }
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
