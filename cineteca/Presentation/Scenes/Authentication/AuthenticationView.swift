import UIKit
import Cartography

protocol AuthenticationViewDelegate: AnyObject {
    func didSubmitEmailPassword(
        email: String,
        username: String,
        password: String,
        mode: AuthenticationModels.Mode,
        confirmation: String
    )
    func didRequestPasswordReset(email: String)
    func didSelectProvider(identifier: String)
    func didTapCancelAuthentication()
}

final class AuthenticationView: UIView {

    // MARK: - Properties

    weak var delegate: AuthenticationViewDelegate?

    private let providers: [AuthenticationModels.ProviderViewModel]
    private var mode: AuthenticationModels.Mode = .signIn {
        didSet { updateMode() }
    }

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.AuthenticationScene.title
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .textPrimary
        label.numberOfLines = 0
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.AuthenticationScene.message
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        return label
    }()

    private lazy var usernameField = makeTextField(
        placeholder: Strings.AuthenticationScene.username,
        keyboardType: .default
    )
    private lazy var emailField = makeTextField(
        placeholder: Strings.AuthenticationScene.email,
        keyboardType: .emailAddress
    )
    private lazy var passwordField = makeTextField(
        placeholder: Strings.AuthenticationScene.password,
        keyboardType: .default,
        secure: true
    )
    private lazy var confirmationField = makeTextField(
        placeholder: Strings.AuthenticationScene.confirmPassword,
        keyboardType: .default,
        secure: true
    )

    private lazy var fieldsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            usernameField,
            emailField,
            passwordField,
            confirmationField
        ])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private lazy var submitButton: UIButton = {
        let button = makeButton()
        button.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        return button
    }()

    private lazy var modeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.textPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.addTarget(self, action: #selector(didTapMode), for: .touchUpInside)
        return button
    }()

    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.AuthenticationScene.forgotPassword, for: .normal)
        button.setTitleColor(.textSecondary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        return button
    }()

    private lazy var providerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private lazy var cancelButton: UIButton = {
        let button = makeButton()
        button.setTitle(Strings.AuthenticationScene.cancel, for: .normal)
        button.setTitleColor(.textPrimary, for: .normal)
        button.backgroundColor = .cardBackground
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization

    init(providers: [AuthenticationModels.ProviderViewModel]) {
        self.providers = providers
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        setupSubviews()
        setupProviderButtons()
        updateMode()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(fieldsStack)
        addSubview(submitButton)
        addSubview(modeButton)
        addSubview(resetButton)
        addSubview(providerStack)
        addSubview(cancelButton)
    }

    private func setupProviderButtons() {
        providers.forEach { provider in
            let button = makeButton()
            button.setTitle(provider.title, for: .normal)
            button.accessibilityIdentifier = "authentication.provider.\(provider.identifier)"
            button.addAction(
                UIAction { [weak self] _ in
                    self?.delegate?.didSelectProvider(identifier: provider.identifier)
                },
                for: .touchUpInside
            )
            providerStack.addArrangedSubview(button)
        }
        providerStack.isHidden = providers.isEmpty
    }

    private func setupConstraints() {
        constrainTitleLabel()
        constrainMessageLabel()
        constrainFieldsStack()
        constrainSubmitButton()
        constrainModeButton()
        constrainResetButton()
        constrainProviderStack()
        constrainCancelButton()
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, self) { title, superview in
            title.top == superview.safeAreaLayoutGuide.top + 32
            title.left == superview.left + 24
            title.right == superview.right - 24
        }
    }

    private func constrainMessageLabel() {
        constrain(messageLabel, titleLabel, self) { message, title, superview in
            message.top == title.bottom + 12
            message.left == superview.left + 24
            message.right == superview.right - 24
        }
    }

    private func constrainFieldsStack() {
        constrain(fieldsStack, messageLabel, self) { fields, message, superview in
            fields.top == message.bottom + 24
            fields.left == superview.left + 24
            fields.right == superview.right - 24
        }
    }

    private func constrainSubmitButton() {
        constrain(submitButton, fieldsStack, self) { button, fields, superview in
            button.top == fields.bottom + 20
            button.left == superview.left + 24
            button.right == superview.right - 24
            button.height == 44
        }
    }

    private func constrainModeButton() {
        constrain(modeButton, submitButton, self) { mode, submit, superview in
            mode.top == submit.bottom + 12
            mode.centerX == superview.centerX
        }
    }

    private func constrainResetButton() {
        constrain(resetButton, modeButton, self) { reset, mode, superview in
            reset.top == mode.bottom + 8
            reset.centerX == superview.centerX
        }
    }

    private func constrainProviderStack() {
        constrain(providerStack, resetButton, self) { providers, reset, superview in
            providers.top == reset.bottom + 16
            providers.left == superview.left + 24
            providers.right == superview.right - 24
        }
    }

    private func constrainCancelButton() {
        constrain(cancelButton, providerStack, self) { cancel, providers, superview in
            cancel.top == providers.bottom + 24
            cancel.left == superview.left + 24
            cancel.right == superview.right - 24
            cancel.height == 44
            cancel.bottom <= superview.safeAreaLayoutGuide.bottom - 24
        }
    }

    // MARK: - Helpers

    private func makeTextField(
        placeholder: String,
        keyboardType: UIKeyboardType,
        secure: Bool = false
    ) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.textColor = .textPrimary
        field.tintColor = .accentYellow
        field.backgroundColor = .cardBackground
        field.layer.cornerRadius = 12
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        field.rightViewMode = .always
        field.heightAnchor.constraint(equalToConstant: 48).isActive = true
        field.keyboardType = keyboardType
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.isSecureTextEntry = secure
        return field
    }

    private func makeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .accentYellow
        button.layer.cornerRadius = 22
        return button
    }

    private func updateMode() {
        let isSignUp = mode == .signUp
        usernameField.isHidden = !isSignUp
        confirmationField.isHidden = !isSignUp
        submitButton.setTitle(
            isSignUp ? Strings.AuthenticationScene.signUp : Strings.AuthenticationScene.signIn,
            for: .normal
        )
        modeButton.setTitle(
            isSignUp ? Strings.AuthenticationScene.signIn : Strings.AuthenticationScene.signUp,
            for: .normal
        )
        resetButton.isHidden = isSignUp
    }

    // MARK: - Actions

    @objc private func didTapSubmit() {
        delegate?.didSubmitEmailPassword(
            email: emailField.text ?? "",
            username: usernameField.text ?? "",
            password: passwordField.text ?? "",
            mode: mode,
            confirmation: confirmationField.text ?? ""
        )
    }

    @objc private func didTapMode() {
        mode = mode == .signIn ? .signUp : .signIn
    }

    @objc private func didTapReset() {
        delegate?.didRequestPasswordReset(email: emailField.text ?? "")
    }

    @objc private func didTapCancel() {
        delegate?.didTapCancelAuthentication()
    }
}
