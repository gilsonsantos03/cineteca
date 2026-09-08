import UIKit
import Cartography

protocol EditProfileViewDelegate: AnyObject {
    func didTapBack()
    func didTapCancel()
    func didTapSave(displayName: String, bio: String)
    func didTapChangePhoto()
}

final class EditProfileView: UIView {

    // MARK: - Properties

    weak var delegate: EditProfileViewDelegate?

    // MARK: - UI Components

    private lazy var contentView = EditProfileContentView()

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

    func showContent(content: EditProfileModels.FetchProfile.ViewModel.Content) {
        loadingIndicator.stopAnimating()
        contentView.configure(content: content)
        contentView.isHidden = false
    }

    func showError() {
        loadingIndicator.stopAnimating()
        contentView.isHidden = true
    }

    func showSaveError() {
        contentView.setSaving(false)
    }

    func setSaving(_ isSaving: Bool) {
        contentView.setSaving(isSaving)
    }
}

// MARK: - EditProfileContentViewDelegate

extension EditProfileView: EditProfileContentViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }

    func didTapCancel() {
        delegate?.didTapCancel()
    }

    func didTapSave(displayName: String, bio: String) {
        delegate?.didTapSave(displayName: displayName, bio: bio)
    }

    func didTapChangePhoto() {
        delegate?.didTapChangePhoto()
    }
}
