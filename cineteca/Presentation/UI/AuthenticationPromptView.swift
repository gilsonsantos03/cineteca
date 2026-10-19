import UIKit
import Cartography

protocol AuthenticationPromptViewDelegate: AnyObject {
    func didTapAuthenticationPrompt()
}

final class AuthenticationPromptView: UIView {
    weak var delegate: AuthenticationPromptViewDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.AuthenticationScene.promptTitle
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.AuthenticationScene.promptMessage
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.AuthenticationScene.promptAction, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .accentYellow
        button.layer.cornerRadius = 22
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(actionButton)
        constrain(titleLabel, self) { title, superview in
            title.top == superview.top
            title.centerX == superview.centerX
            title.left == superview.left + 24
            title.right == superview.right - 24
        }
        constrain(messageLabel, titleLabel, self) { message, title, superview in
            message.top == title.bottom + 10
            message.left == superview.left + 24
            message.right == superview.right - 24
        }
        constrain(actionButton, messageLabel, self) { button, message, superview in
            button.top == message.bottom + 24
            button.centerX == superview.centerX
            button.width == 220
            button.bottom == superview.bottom
        }
    }

    @objc private func didTapAction() {
        delegate?.didTapAuthenticationPrompt()
    }
}
