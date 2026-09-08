import UIKit
import Cartography

final class PasswordFormFieldView: UIView {

    // MARK: - Properties

    private var isSecure = true

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .textPrimary
        textField.tintColor = .accentYellow
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private lazy var visibilityButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        button.setImage(UIImage(systemName: "eye.slash", withConfiguration: config), for: .normal)
        button.tintColor = .textSecondary
        button.addTarget(self, action: #selector(didTapVisibility), for: .touchUpInside)
        return button
    }()

    private lazy var inputContainerView: UIView = {
        let container = UIView()
        container.backgroundColor = .cardBackground
        container.layer.cornerRadius = 12
        return container
    }()

    // MARK: - Initialization

    init(title: String, placeholder: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.textSecondary]
        )
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(inputContainerView)
        inputContainerView.addSubview(textField)
        inputContainerView.addSubview(visibilityButton)
    }

    private func setupConstraints() {
        constrainTitleLabel()
        constrainInputContainerView()
        constrainTextField()
        constrainVisibilityButton()
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, self) { label, superview in
            label.top == superview.top
            label.left == superview.left
            label.right == superview.right
        }
    }

    private func constrainInputContainerView() {
        constrain(inputContainerView, titleLabel, self) { container, title, superview in
            container.top == title.bottom + 8
            container.left == superview.left
            container.right == superview.right
            container.bottom == superview.bottom
        }
    }

    private func constrainTextField() {
        constrain(textField, visibilityButton, inputContainerView) { textField, button, container in
            textField.top == container.top + 14
            textField.bottom == container.bottom - 14
            textField.left == container.left + 14
            textField.right == button.left - 8
        }
    }

    private func constrainVisibilityButton() {
        constrain(visibilityButton, inputContainerView) { button, container in
            button.centerY == container.centerY
            button.right == container.right - 14
            button.width == 24
            button.height == 24
        }
    }

    // MARK: - Public API

    func currentText() -> String {
        textField.text ?? ""
    }

    func clear() {
        textField.text = ""
    }

    // MARK: - Actions

    @objc private func didTapVisibility() {
        isSecure.toggle()
        textField.isSecureTextEntry = isSecure
        let symbolName = isSecure ? "eye.slash" : "eye"
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        visibilityButton.setImage(UIImage(systemName: symbolName, withConfiguration: config), for: .normal)
    }
}
