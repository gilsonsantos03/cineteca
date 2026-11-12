import UIKit
import Cartography

protocol MovieRecommendationErrorViewDelegate: AnyObject {
    func didRequestRetry()
}

final class MovieRecommendationErrorView: UIStackView {

    // MARK: - Properties

    weak var delegate: MovieRecommendationErrorViewDelegate?

    // MARK: - UI Components

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimary
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = Strings.MovieRecommendationScene.retryButton
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 8,
            bottom: 10,
            trailing: 8
        )
        configuration.baseForegroundColor = .accentYellow

        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "movieRecommendation.retryButton"
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        axis = .vertical
        spacing = 12
        alignment = .fill
        setupSubviews()
    }

    private func setupSubviews() {
        addArrangedSubview(messageLabel)
        addArrangedSubview(retryButton)
    }

    // MARK: - Configure

    func configure(message: String) {
        messageLabel.text = message
    }

    // MARK: - Actions

    @objc private func retryTapped() {
        delegate?.didRequestRetry()
    }
}
