import UIKit
import Cartography

protocol MovieRecommendationErrorViewDelegate: AnyObject {
    func didRequestRetry()
    func didRequestNewRecommendation()
}

final class MovieRecommendationErrorView: UIView {
    weak var delegate: MovieRecommendationErrorViewDelegate?

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 36
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
        let view = UIImageView(
            image: UIImage(systemName: "exclamationmark.triangle", withConfiguration: configuration)
        )
        view.tintColor = .accentYellow
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieRecommendationScene.errorTitle
        label.textColor = .textPrimary
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textSecondary
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.MovieRecommendationScene.retryButton, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .accentYellow
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "movieRecommendation.retryButton"
        return button
    }()

    private lazy var newRecommendationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.MovieRecommendationScene.newRecommendation, for: .normal)
        button.setTitleColor(.textPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .cardBackground
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(newRecommendationTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [retryButton, newRecommendationButton])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        backgroundColor = .clear
        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(buttonsStack)
        setupConstraints()
    }

    private func setupConstraints() {
        constrainIconContainerView()
        constrainIconImageView()
        constrainTitleLabel()
        constrainMessageLabel()
        constrainButtonsStack()
        constrainRetryButton()
        constrainNewRecommendationButton()
    }

    private func constrainIconContainerView() {
        constrain(iconContainerView, self) { container, superview in
            container.top == superview.top + 40
            container.centerX == superview.centerX
            container.width == 72
            container.height == 72
        }
    }

    private func constrainIconImageView() {
        constrain(iconImageView, iconContainerView) { imageView, container in
            imageView.center == container.center
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, iconContainerView, self) { label, iconContainer, superview in
            label.top == iconContainer.bottom + 24
            label.leading == superview.leading + 16
            label.trailing == superview.trailing - 16
        }
    }

    private func constrainMessageLabel() {
        constrain(messageLabel, titleLabel, self) { label, title, superview in
            label.top == title.bottom + 8
            label.leading == superview.leading + 16
            label.trailing == superview.trailing - 16
        }
    }

    private func constrainButtonsStack() {
        constrain(buttonsStack, messageLabel, self) { stack, message, superview in
            stack.top == message.bottom + 32
            stack.leading == superview.leading
            stack.trailing == superview.trailing
            stack.bottom == superview.bottom
        }
    }

    private func constrainRetryButton() {
        constrain(retryButton) { button in
            button.height == 44
        }
    }

    private func constrainNewRecommendationButton() {
        constrain(newRecommendationButton) { button in
            button.height == 44
        }
    }

    func configure(message: String) {
        messageLabel.text = message
    }

    @objc private func retryTapped() {
        delegate?.didRequestRetry()
    }

    @objc private func newRecommendationTapped() {
        delegate?.didRequestNewRecommendation()
    }
}
