import UIKit
import Cartography

protocol MovieDetailsErrorViewDelegate: AnyObject {
    func didRequestRetry()
}

final class MovieDetailsErrorView: UIStackView {

    // MARK: - Properties

    weak var delegate: MovieDetailsErrorViewDelegate?

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .textPrimary
        label.numberOfLines = 0
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.MovieDetailsScene.Error.retry, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .accentYellow
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        axis = .vertical
        spacing = 12
        alignment = .fill

        addArrangedSubview(titleLabel)
        addArrangedSubview(messageLabel)
        addArrangedSubview(retryButton)

        constrain(retryButton) { button in
            button.height == 44
        }
    }

    // MARK: - Configure

    func configure(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }

    // MARK: - Actions

    @objc private func didTapRetry() {
        delegate?.didRequestRetry()
    }
}
