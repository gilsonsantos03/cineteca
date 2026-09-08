import UIKit
import Cartography

protocol ChangePasswordContentViewDelegate: AnyObject {
    func didTapBack()
    func didTapUpdatePassword(currentPassword: String, newPassword: String, confirmPassword: String)
}

final class ChangePasswordContentView: UIView {

    // MARK: - Properties

    weak var delegate: ChangePasswordContentViewDelegate?

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .appBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    private lazy var headerView = BackNavigationHeaderView(title: Strings.ChangePasswordScene.title)

    private lazy var currentPasswordField = PasswordFormFieldView(
        title: Strings.ChangePasswordScene.Field.currentPassword,
        placeholder: Strings.ChangePasswordScene.Field.currentPasswordPlaceholder
    )

    private lazy var newPasswordField = PasswordFormFieldView(
        title: Strings.ChangePasswordScene.Field.newPassword,
        placeholder: Strings.ChangePasswordScene.Field.newPasswordPlaceholder
    )

    private lazy var confirmPasswordField = PasswordFormFieldView(
        title: Strings.ChangePasswordScene.Field.confirmPassword,
        placeholder: Strings.ChangePasswordScene.Field.confirmPasswordPlaceholder
    )

    private lazy var updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.ChangePasswordScene.updatePassword, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .accentYellow
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(didTapUpdatePassword), for: .touchUpInside)
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
        headerView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(currentPasswordField)
        contentStack.addArrangedSubview(newPasswordField)
        contentStack.addArrangedSubview(confirmPasswordField)
        contentStack.addArrangedSubview(updateButton)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
    }

    private func setupConstraints() {
        constrainScrollView()
        constrainContentStack()
        constrainUpdateButton()
    }

    private func constrainScrollView() {
        constrain(scrollView, self) { scroll, superview in
            scroll.top == superview.safeAreaLayoutGuide.top + 8
            scroll.bottom == superview.bottom
            scroll.left == superview.left
            scroll.right == superview.right
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView) { stack, scroll in
            stack.top == scroll.top
            stack.left == scroll.left + 20
            stack.right == scroll.right - 20
            stack.bottom == scroll.bottom
            stack.width == scroll.width - 40
        }
    }

    private func constrainUpdateButton() {
        constrain(updateButton) { button in
            button.height == 44
        }
    }

    // MARK: - Public API

    func setUpdating(_ isUpdating: Bool) {
        updateButton.isEnabled = !isUpdating
        updateButton.alpha = isUpdating ? 0.6 : 1
    }

    // MARK: - Actions

    @objc private func didTapUpdatePassword() {
        endEditing(true)
        delegate?.didTapUpdatePassword(
            currentPassword: currentPasswordField.currentText(),
            newPassword: newPasswordField.currentText(),
            confirmPassword: confirmPasswordField.currentText()
        )
    }

    // MARK: - Helpers

    private func makeSpacer(height: CGFloat) -> UIView {
        let view = UIView()
        constrain(view) { spacer in
            spacer.height == height
        }
        return view
    }
}

extension ChangePasswordContentView: BackNavigationHeaderViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }
}
