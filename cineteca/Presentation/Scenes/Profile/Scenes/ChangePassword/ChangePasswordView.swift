import UIKit
import Cartography

protocol ChangePasswordViewDelegate: AnyObject {
    func didTapBack()
    func didTapUpdatePassword(currentPassword: String, newPassword: String, confirmPassword: String)
}

final class ChangePasswordView: UIView {

    // MARK: - Properties

    weak var delegate: ChangePasswordViewDelegate?

    // MARK: - UI Components

    private lazy var contentView = ChangePasswordContentView()

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
        addSubview(contentView)
        constrain(contentView, self) { view, superview in
            view.edges == superview.edges
        }
    }

    // MARK: - Public API

    func setUpdating(_ isUpdating: Bool) {
        contentView.setUpdating(isUpdating)
    }
}

extension ChangePasswordView: ChangePasswordContentViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }

    func didTapUpdatePassword(currentPassword: String, newPassword: String, confirmPassword: String) {
        delegate?.didTapUpdatePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )
    }
}
