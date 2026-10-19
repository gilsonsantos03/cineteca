import UIKit
import Cartography

protocol MovieCatalogLoadingFooterViewDelegate: AnyObject {
    func didTapLoadMore()
}

final class MovieCatalogLoadingFooterView: UICollectionReusableView {
    static let reuseId = "MovieCatalogLoadingFooterView"

    // MARK: - Properties

    weak var delegate: MovieCatalogLoadingFooterViewDelegate?

    // MARK: - UI Components

    private lazy var loadMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = makeButtonConfiguration()
        button.accessibilityLabel = Strings.MovieCatalogScene.loadMore
        button.addTarget(self, action: #selector(didTapLoadMore), for: .touchUpInside)
        return button
    }()

    private lazy var buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(
            string: Strings.MovieCatalogScene.loadMore.uppercased(),
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.textPrimary,
                .kern: 1.2
            ]
        )
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 18
        view.layer.borderColor = UIColor.textSecondary.withAlphaComponent(0.18).cgColor
        view.layer.borderWidth = 1
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(
                systemName: "chevron.down",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 16,
                    weight: .regular
                )
            )
        )
        imageView.tintColor = .accentYellow
        imageView.contentMode = .center
        return imageView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            buttonTitleLabel,
            iconBackgroundView
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .accentYellow
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(loadMoreButton)
        loadMoreButton.addSubview(contentStackView)
        iconBackgroundView.addSubview(chevronImageView)
        loadMoreButton.addSubview(loadingIndicator)
    }

    private func setupConstraints() {
        constrainLoadMoreButton()
        constrainContentStackView()
        constrainIconBackgroundView()
        constrainChevronImageView()
        constrainLoadingIndicator()
    }

    private func constrainLoadMoreButton() {
        constrain(loadMoreButton, self) { button, container in
            button.top == container.top + 8
            button.centerX == container.centerX
            button.width >= 170
            button.height == 56
        }
    }

    private func constrainContentStackView() {
        constrain(contentStackView, loadMoreButton) { stack, button in
            stack.centerX == button.centerX
            stack.centerY == button.centerY
            stack.left == button.left + 16
            stack.right == button.right - 16
        }
    }

    private func constrainIconBackgroundView() {
        constrain(iconBackgroundView) { iconBackground in
            iconBackground.width == 32
            iconBackground.height == 32
        }
    }

    private func constrainChevronImageView() {
        constrain(chevronImageView, iconBackgroundView) { chevron, iconBackground in
            chevron.centerX == iconBackground.centerX
            chevron.centerY == iconBackground.centerY
            chevron.width == 18
            chevron.height == 18
        }
    }

    private func constrainLoadingIndicator() {
        constrain(loadingIndicator, loadMoreButton) { indicator, button in
            indicator.centerX == button.centerX
            indicator.centerY == button.centerY
        }
    }

    // MARK: - Configure

    func setLoading(_ isLoading: Bool) {
        loadMoreButton.isEnabled = !isLoading
        loadMoreButton.alpha = isLoading ? 0.8 : 1
        buttonTitleLabel.isHidden = isLoading
        iconBackgroundView.isHidden = isLoading

        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }

    private func makeButtonConfiguration() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .textPrimary
        configuration.background.backgroundColor = .cardBackground
        configuration.background.strokeColor = UIColor.textSecondary.withAlphaComponent(0.18)
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 28
        return configuration
    }

    // MARK: - Actions

    @objc private func didTapLoadMore() {
        delegate?.didTapLoadMore()
    }
}
