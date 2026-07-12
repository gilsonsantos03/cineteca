import UIKit
import Cartography

protocol HomeErrorStateViewDelegate: AnyObject {
    func homeErrorStateViewDidRequestRetry(_ view: HomeErrorStateView)
}

final class HomeErrorStateView: UIView {

    // MARK: - Properties

    weak var delegate: HomeErrorStateViewDelegate?

    // MARK: - UI Components

    private lazy var iconImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 48, weight: .regular)
        let imageView = UIImageView(image: UIImage(systemName: "wifi.exclamationmark", withConfiguration: config))
        imageView.tintColor = .textSecondary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.HomeScene.Error.title
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.HomeScene.Error.subtitle
        label.font = .systemFont(ofSize: 14)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.HomeScene.Error.retryButton, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .accentYellow
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
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
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(retryButton)
    }

    private func setupConstraints() {
        constrainIconImageView()
        constrainTitleLabel()
        constrainSubtitleLabel()
        constrainRetryButton()
    }

    private func constrainIconImageView() {
        constrain(iconImageView, self) { imageView, superview in
            imageView.centerX == superview.centerX
            imageView.centerY == superview.centerY - 60
            imageView.width == 56
            imageView.height == 56
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, iconImageView, self) { label, imageView, superview in
            label.top == imageView.bottom + 20
            label.left == superview.left + 32
            label.right == superview.right - 32
        }
    }

    private func constrainSubtitleLabel() {
        constrain(subtitleLabel, titleLabel, self) { label, title, superview in
            label.top == title.bottom + 8
            label.left == superview.left + 32
            label.right == superview.right - 32
        }
    }

    private func constrainRetryButton() {
        constrain(retryButton, subtitleLabel, self) { button, subtitle, superview in
            button.top == subtitle.bottom + 24
            button.centerX == superview.centerX
            button.width == 160
            button.height == 44
        }
    }

    // MARK: - Actions

    @objc private func didTapRetry() {
        delegate?.homeErrorStateViewDidRequestRetry(self)
    }
}
