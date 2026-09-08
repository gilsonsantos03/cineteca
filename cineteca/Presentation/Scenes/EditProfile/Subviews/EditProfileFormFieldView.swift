import UIKit
import Cartography

enum EditProfileFormFieldStyle {
    case singleLine
    case multiline
}

final class EditProfileFormFieldView: UIView, UITextViewDelegate {

    // MARK: - Properties

    private let style: EditProfileFormFieldStyle
    private let isEditable: Bool

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
        textField.textColor = .white
        textField.tintColor = .accentYellow
        textField.isEnabled = isEditable
        return textField
    }()

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .white
        textView.tintColor = .accentYellow
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        return textView
    }()

    private lazy var inputContainerView: UIView = {
        let container = UIView()
        container.backgroundColor = .cardBackground
        container.layer.cornerRadius = 12
        return container
    }()

    // MARK: - Initialization

    init(title: String, style: EditProfileFormFieldStyle, isEditable: Bool = true) {
        self.style = style
        self.isEditable = isEditable
        super.init(frame: .zero)
        titleLabel.text = title
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

        switch style {
        case .singleLine:
            inputContainerView.addSubview(textField)
        case .multiline:
            inputContainerView.addSubview(textView)
        }
    }

    private func setupConstraints() {
        constrainTitleLabel()
        constrainInputContainerView()
        switch style {
        case .singleLine:
            constrainTextField()
        case .multiline:
            constrainTextView()
        }
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
        constrain(textField, inputContainerView) { textField, container in
            textField.top == container.top + 14
            textField.bottom == container.bottom - 14
            textField.left == container.left + 14
            textField.right == container.right - 14
        }
    }

    private func constrainTextView() {
        constrain(textView, inputContainerView) { textView, container in
            textView.top == container.top + 12
            textView.bottom == container.bottom - 12
            textView.left == container.left + 14
            textView.right == container.right - 14
            textView.height >= 88
        }
    }

    // MARK: - Configure

    func configure(text: String) {
        switch style {
        case .singleLine:
            textField.text = text
        case .multiline:
            textView.text = text
        }
    }

    func currentText() -> String {
        switch style {
        case .singleLine:
            return textField.text ?? ""
        case .multiline:
            return textView.text ?? ""
        }
    }
}
