import UIKit
import Cartography

final class FeaturedView: UIView {

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

    private lazy var imdbBadgeView: UIView = {
        let container = UIView()
        container.backgroundColor = .accentYellow
        container.layer.cornerRadius = 6
        return container
    }()

    private lazy var imdbRatingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .black
        return label
    }()

    private lazy var imdbBadgeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imdbBadgeLabel, imdbRatingLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()

    private lazy var yearLabel: UILabel = {
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

    private lazy var genreChipStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()

    private lazy var watchTrailerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.HomeScene.Featured.watchTrailerButton, for: .normal)
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
        button.setTitle(Strings.HomeScene.Featured.watchlistButton, for: .normal)
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

    private lazy var ratingYearRow: UIStackView = {
        let row = UIStackView(arrangedSubviews: [imdbBadgeView, yearLabel])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        return row
    }()

    private lazy var actionButtonRow: UIStackView = {
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
        imdbBadgeView.addSubview(imdbBadgeStack)
        addSubview(ratingYearRow)
        addSubview(titleLabel)
        addSubview(genreChipStack)
        addSubview(actionButtonRow)
    }

    private func setupConstraints() {
        constrainBackdropImageView()
        constrainNotificationButton()
        constrainImdbBadgeStack()
        constrainActionButtonRow()
        constrainGenreChipStack()
        constrainTitleLabel()
        constrainRatingYearRow()
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

    private func constrainImdbBadgeStack() {
        constrain(imdbBadgeStack, imdbBadgeView) { stack, container in
            stack.top == container.top + 3
            stack.bottom == container.bottom - 3
            stack.left == container.left + 6
            stack.right == container.right - 6
        }
    }

    private func constrainActionButtonRow() {
        constrain(actionButtonRow, backdropImageView, self) { row, imageView, superview in
            row.left == superview.left + 20
            row.right == superview.right - 20
            row.bottom == imageView.bottom - 20
            row.height == 44
        }
    }

    private func constrainGenreChipStack() {
        constrain(genreChipStack, actionButtonRow) { stack, row in
            stack.left == row.left
            stack.bottom == row.top - 16
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, genreChipStack) { label, stack in
            label.left == stack.left
            label.right == stack.right + 200
            label.bottom == stack.top - 10
        }
    }

    private func constrainRatingYearRow() {
        constrain(ratingYearRow, titleLabel) { row, label in
            row.left == label.left
            row.bottom == label.top - 8
        }
    }

    // MARK: - Configure

    func configure(viewModel: FeaturedViewModel) {
        backdropImageView.loadImage(from: viewModel.backdropURL)
        titleLabel.text = viewModel.title
        imdbRatingLabel.text = viewModel.rating
        yearLabel.text = viewModel.year

        genreChipStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        viewModel.genres.forEach { genre in
            let chip = makeGenreChip(genre)
            genreChipStack.addArrangedSubview(chip)
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
