import UIKit
import Cartography

protocol ProfileViewDelegate: AnyObject {
    func didTapEdit()
    func didTapFavoriteFilm(movieId: Int)
    func didTapSeeAllReviews()
    func didTapSignOut()
    func didSelectSetting(_ setting: ProfileModels.Setting)
    func didRequestAuthentication()
    func didRequestRetry()
}

final class ProfileView: UIView {

    // MARK: - Properties

    weak var delegate: ProfileViewDelegate?

    // MARK: - UI Components

    private lazy var contentView = ProfileContentView()
    private lazy var authenticationPromptView = AuthenticationPromptView()
    private lazy var errorStateView = ErrorStateView()

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
        contentView.delegate = self
        authenticationPromptView.delegate = self
        errorStateView.delegate = self
        errorStateView.configure(
            viewModel: .init(
                title: Strings.ProfileScene.Error.title,
                subtitle: Strings.ProfileScene.Error.subtitle,
                retryButtonTitle: Strings.ProfileScene.Error.retryButton
            )
        )
        errorStateView.isHidden = true
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(contentView)
        addSubview(loadingIndicator)
        addSubview(authenticationPromptView)
        addSubview(errorStateView)
    }

    private func setupConstraints() {
        constrainContentView()
        constrainLoadingIndicator()
        constrainAuthenticationPromptView()
        constrainErrorStateView()
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

    private func constrainErrorStateView() {
        constrain(errorStateView, self) { error, superview in
            error.edges == superview.edges
        }
    }

    // MARK: - Public API

    func showLoading() {
        contentView.isHidden = true
        authenticationPromptView.isHidden = true
        errorStateView.isHidden = true
        loadingIndicator.startAnimating()
    }

    func showGuest() {
        contentView.isHidden = true
        errorStateView.isHidden = true
        loadingIndicator.stopAnimating()
        authenticationPromptView.isHidden = false
    }

    func showContent(content: ProfileModels.FetchProfile.ViewModel.Content) {
        loadingIndicator.stopAnimating()
        authenticationPromptView.isHidden = true
        errorStateView.isHidden = true
        contentView.configure(content: content)
        contentView.isHidden = false
    }

    func showError() {
        loadingIndicator.stopAnimating()
        authenticationPromptView.isHidden = true
        contentView.isHidden = true
        errorStateView.isHidden = false
    }
}

// MARK: - ProfileContentViewDelegate

extension ProfileView: ProfileContentViewDelegate {
    func didTapEdit() {
        delegate?.didTapEdit()
    }

    func didTapFavoriteFilm(movieId: Int) {
        delegate?.didTapFavoriteFilm(movieId: movieId)
    }

    func didTapSeeAllReviews() {
        delegate?.didTapSeeAllReviews()
    }

    func didTapSignOut() {
        delegate?.didTapSignOut()
    }

    func didSelectSetting(_ setting: ProfileModels.Setting) {
        delegate?.didSelectSetting(setting)
    }
}

extension ProfileView: AuthenticationPromptViewDelegate {
    func didTapAuthenticationPrompt() {
        delegate?.didRequestAuthentication()
    }
}

extension ProfileView: ErrorStateViewDelegate {
    func didRequestRetry() {
        delegate?.didRequestRetry()
    }
}
