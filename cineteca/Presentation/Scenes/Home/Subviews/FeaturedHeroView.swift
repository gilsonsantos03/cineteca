import UIKit
import Cartography

final class FeaturedHeroView: UIView {

    // MARK: - UI Components

    private lazy var backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .cardBackground
        return imageView
    }()

    private let gradientLayer = CAGradientLayer()

    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "bell", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        button.layer.cornerRadius = 20
        return button
    }()

    private lazy var imdbBadgeLabel: UILabel = {
        let label = UILabel()
        label.text = "IMDb"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .black
        return label
    }()

    private lazy var imdbBadge: UIView = {
        let container = UIView()
        container.backgroundColor = .accentYellow
        container.layer.cornerRadius = 6
        return container
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private lazy var metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private lazy var genreStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()

    private lazy var watchTrailerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("  Watch Trailer", for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        button.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .accentYellow
        button.layer.cornerRadius = 22
        return button
    }()

    private lazy var watchlistButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("  Watchlist", for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return button
    }()

    private lazy var metaRow: UIStackView = {
        let row = UIStackView(arrangedSubviews: [imdbBadge, ratingLabel, metaLabel])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }()

    private lazy var buttonRow: UIStackView = {
        let row = UIStackView(arrangedSubviews: [watchTrailerButton, watchlistButton])
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually
        return row
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = backdropImageView.bounds
    }

    // MARK: - Setup

    private func setup() {
        setupGradient()
        setupSubviews()
        setupConstraints()
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.appBackground.withAlphaComponent(0.7).cgColor,
            UIColor.appBackground.cgColor
        ]
        gradientLayer.locations = [0.3, 0.7, 1.0]
        backdropImageView.layer.addSublayer(gradientLayer)
    }

    private func setupSubviews() {
        addSubview(backdropImageView)
        addSubview(notificationButton)
        imdbBadge.addSubview(imdbBadgeLabel)
        addSubview(metaRow)
        addSubview(titleLabel)
        addSubview(genreStack)
        addSubview(buttonRow)
    }

    private func setupConstraints() {
        constrainBackdropImageView()
        constrainNotificationButton()
        constrainImdbBadgeLabel()
        constrainButtonRow()
        constrainGenreStack()
        constrainTitleLabel()
        constrainMetaRow()
    }

    private func constrainBackdropImageView() {
        constrain(backdropImageView, self) { imageView, superview in
            imageView.top == superview.top
            imageView.left == superview.left
            imageView.right == superview.right
            imageView.height == 420
            imageView.bottom == superview.bottom
        }
    }

    private func constrainNotificationButton() {
        constrain(notificationButton, self) { button, superview in
            button.top == superview.safeAreaLayoutGuide.top + 12
            button.right == superview.right - 20
            button.width == 40
            button.height == 40
        }
    }

    private func constrainImdbBadgeLabel() {
        constrain(imdbBadgeLabel, imdbBadge) { label, container in
            label.top == container.top + 3
            label.bottom == container.bottom - 3
            label.left == container.left + 6
            label.right == container.right - 6
        }
    }

    private func constrainButtonRow() {
        constrain(buttonRow, backdropImageView, self) { row, imageView, superview in
            row.left == superview.left + 20
            row.right == superview.right - 20
            row.bottom == imageView.bottom - 20
            row.height == 44
        }
    }

    private func constrainGenreStack() {
        constrain(genreStack, buttonRow) { stack, row in
            stack.left == row.left
            stack.bottom == row.top - 16
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, genreStack) { label, stack in
            label.left == stack.left
            label.right == stack.right + 200
            label.bottom == stack.top - 10
        }
    }

    private func constrainMetaRow() {
        constrain(metaRow, titleLabel) { row, label in
            row.left == label.left
            row.bottom == label.top - 8
        }
    }

    // MARK: - Configure

    func configure(viewModel: FeaturedViewModel) {
        backdropImageView.loadImage(from: viewModel.backdropURL)
        titleLabel.text = viewModel.title
        ratingLabel.text = viewModel.rating
        metaLabel.text = "\(viewModel.year) · \(viewModel.runtime)"

        genreStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        viewModel.genres.forEach { genre in
            let chip = makeGenreChip(genre)
            genreStack.addArrangedSubview(chip)
        }
    }

    // MARK: - Helpers

    private func makeGenreChip(_ text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white

        container.addSubview(label)
        constrain(label, container) { label, container in
            label.top == container.top + 5
            label.bottom == container.bottom - 5
            label.left == container.left + 10
            label.right == container.right - 10
        }
        return container
    }
}
