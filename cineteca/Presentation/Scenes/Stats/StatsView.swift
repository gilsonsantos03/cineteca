import UIKit
import Cartography

protocol StatsViewDelegate: AnyObject {
    func didRequestAuthentication()
}

final class StatsView: UIView {
    weak var delegate: StatsViewDelegate?

    // MARK: - UI Components

    private lazy var contentView = StatsContentView()
    private lazy var authenticationPromptView = AuthenticationPromptView()

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
        authenticationPromptView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(contentView)
        addSubview(loadingIndicator)
        addSubview(authenticationPromptView)
    }

    private func setupConstraints() {
        constrainContentView()
        constrainLoadingIndicator()
        constrainAuthenticationPromptView()
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

    private func constrainAuthenticationPromptView() {
        constrain(authenticationPromptView, self) { prompt, superview in
            prompt.centerY == superview.centerY
            prompt.left == superview.left + 20
            prompt.right == superview.right - 20
        }
    }

    // MARK: - Public API

    func showLoading() {
        contentView.isHidden = true
        authenticationPromptView.isHidden = true
        loadingIndicator.startAnimating()
    }

    func showGuest() {
        contentView.isHidden = true
        loadingIndicator.stopAnimating()
        authenticationPromptView.isHidden = false
    }

    func showContent(content: StatsModels.FetchStats.ViewModel.Content) {
        loadingIndicator.stopAnimating()
        authenticationPromptView.isHidden = true
        contentView.configure(content: content)
        contentView.isHidden = false
    }

    func showError() {
        loadingIndicator.stopAnimating()
        authenticationPromptView.isHidden = true
        contentView.isHidden = true
    }
}

extension StatsView: AuthenticationPromptViewDelegate {
    func didTapAuthenticationPrompt() {
        delegate?.didRequestAuthentication()
    }
}
