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
        didSet { contentView.onRefresh = onRefresh }
    }

    var onRetry: (() -> Void)? {
        didSet { errorView.onRetry = onRetry }
    }

    // MARK: - UI Components

    private lazy var skeletonView = HomeSkeletonView()
    private lazy var contentView = HomeContentView()
    private lazy var errorView = HomeErrorStateView()

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
        addSubview(contentView)
        addSubview(errorView)
        addSubview(skeletonView)
    }

    private func setupConstraints() {
        constrainSkeletonView()
        constrainContentView()
        constrainErrorView()
    }

    private func constrainSkeletonView() {
        constrain(skeletonView, self) { view, superview in
            view.edges == superview.edges
        }
    }

    private func constrainContentView() {
        constrain(contentView, self) { view, superview in
            view.edges == superview.edges
        }
    }

    private func constrainErrorView() {
        constrain(errorView, self) { view, superview in
            view.edges == superview.edges
        }
    }

    // MARK: - Public API

    func showLoading() {
        setState(.loading)
    }

    func showContent(viewModel: HomeModels.FetchContent.ViewModel) {
        contentView.configure(viewModel: viewModel)
        setState(.content)
    }

    func showError() {
        setState(.error)
    }

    func endRefreshing() {
        contentView.endRefreshing()
    }

    // MARK: - Helpers

    private func setState(_ state: State) {
        skeletonView.isHidden = state != .loading
        contentView.isHidden = state != .content
        errorView.isHidden = state != .error
    }
}
