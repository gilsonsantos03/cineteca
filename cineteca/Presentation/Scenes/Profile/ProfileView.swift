import UIKit
import Cartography

final class ProfileView: UIView {

    // MARK: - UI Components

    private lazy var contentView = ProfileContentView()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .accentYellow
        indicator.hidesWhenStopped = true
        return indicator
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
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(contentView)
        addSubview(loadingIndicator)
    }

    private func setupConstraints() {
        constrainContentView()
        constrainLoadingIndicator()
    }

    private func constrainContentView() {
        constrain(contentView, self) { view, superview in
            view.edges == superview.edges
        }
    }

    private func constrainLoadingIndicator() {
        constrain(loadingIndicator, self) { indicator, superview in
            indicator.centerX == superview.centerX
            indicator.centerY == superview.centerY
        }
    }

    // MARK: - Public API

    func showLoading() {
        contentView.isHidden = true
        loadingIndicator.startAnimating()
    }

    func showContent(content: ProfileModels.FetchProfile.ViewModel.Content) {
        loadingIndicator.stopAnimating()
        contentView.configure(content: content)
        contentView.isHidden = false
    }

    func showError() {
        loadingIndicator.stopAnimating()
        contentView.isHidden = true
    }
}
