import UIKit
import Cartography

protocol FeaturedViewDelegate: AnyObject {
    func didRequestWatchTrailer(movieId: Int)
    func didTapWatchlist(movieId: Int, isInWatchlist: Bool)
    func didSelectMovie(id movieId: Int)
}

final class FeaturedView: UIView {

    // MARK: - Properties

    weak var delegate: FeaturedViewDelegate?
    private var movieId: Int?
    private var isInWatchlist = false

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

    private lazy var tmdbBadgeLabel: UILabel = {
        let label = UILabel()
        label.text = "TMDB"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .black
        return label
    }()

    private lazy var tmdbBadgeView: UIView = {
        let container = UIView()
        container.backgroundColor = .accentYellow
        container.layer.cornerRadius = 6
        return container
    }()

    private lazy var tmdbRatingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .black
        return label
    }()

    private lazy var tmdbBadgeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [tmdbBadgeLabel, tmdbRatingLabel])
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

    private lazy var watchTrailerButton: WatchTrailerButton = {
        let button = WatchTrailerButton()
        button.delegate = self
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
        button.addTarget(self, action: #selector(didTapWatchlist), for: .touchUpInside)
        return button
    }()

    private lazy var ratingYearRow: UIStackView = {
        let row = UIStackView(arrangedSubviews: [tmdbBadgeView, yearLabel])
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
        updateGradientColors()
    }

    // MARK: - Setup

    private func setup() {
        setupGradient()
        setupSubviews()
        setupConstraints()
        backdropImageView.isUserInteractionEnabled = true
        backdropImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapMovie))
        )
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        updateGradientColors()
    }

    private func setupGradient() {
        gradientLayer.locations = [0.3, 0.7, 1.0]
        backdropImageView.layer.addSublayer(gradientLayer)
        updateGradientColors()
    }

    private func updateGradientColors() {
        let background = UIColor.appBackground.resolvedColor(with: traitCollection)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            background.withAlphaComponent(0.7).cgColor,
            background.cgColor
        ]
    }

    private func setupSubviews() {
        addSubview(backdropImageView)
        addSubview(notificationButton)
        tmdbBadgeView.addSubview(tmdbBadgeStack)
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
            imageView.leading == superview.leading
            imageView.trailing == superview.trailing
            imageView.height == 420
            imageView.bottom == superview.bottom
        }
    }

    private func constrainNotificationButton() {
        constrain(notificationButton, self) { button, superview in
            button.top == superview.safeAreaLayoutGuide.top + 12
            button.trailing == superview.trailing - 20
            button.width == 40
            button.height == 40
        }
    }

    private func constrainImdbBadgeStack() {
        constrain(tmdbBadgeStack, tmdbBadgeView) { stack, container in
            stack.top == container.top + 3
            stack.bottom == container.bottom - 3
            stack.leading == container.leading + 6
            stack.trailing == container.trailing - 6
        }
    }

    private func constrainActionButtonRow() {
        constrain(actionButtonRow, backdropImageView, self) { row, imageView, superview in
            row.leading == superview.leading + 20
            row.trailing == superview.trailing - 20
            row.bottom == imageView.bottom - 20
            row.height == 44
        }
    }

    private func constrainGenreChipStack() {
        constrain(genreChipStack, actionButtonRow) { stack, row in
            stack.leading == row.leading
            stack.bottom == row.top - 16
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, genreChipStack) { label, stack in
            label.leading == stack.leading
            label.trailing == stack.trailing + 200
            label.bottom == stack.top - 10
        }
    }

    private func constrainRatingYearRow() {
        constrain(ratingYearRow, titleLabel) { row, label in
            row.leading == label.leading
            row.bottom == label.top - 8
        }
    }

    // MARK: - Configure

    func configure(viewModel: HomeModels.FeaturedViewModel) {
        movieId = viewModel.movieId
        backdropImageView.loadImage(from: viewModel.backdropURL)
        titleLabel.text = viewModel.title
        tmdbRatingLabel.text = viewModel.rating
        yearLabel.text = viewModel.year
        updateWatchlist(isInWatchlist: viewModel.isInWatchlist)

        genreChipStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        viewModel.genres.forEach { genre in
            let chip = makeGenreChip(genre)
            genreChipStack.addArrangedSubview(chip)
        }
    }

    // MARK: - Actions

    private func didTapWatchTrailer() {
        guard let movieId else { return }
        delegate?.didRequestWatchTrailer(movieId: movieId)
    }

    @objc private func didTapWatchlist() {
        guard let movieId else { return }
        delegate?.didTapWatchlist(
            movieId: movieId,
            isInWatchlist: !isInWatchlist
        )
    }

    @objc private func didTapMovie() {
        guard let movieId else { return }
        delegate?.didSelectMovie(id: movieId)
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
            label.leading == container.leading + 10
            label.trailing == container.trailing - 10
        }
        return container
    }

    func updateWatchlist(isInWatchlist: Bool) {
        self.isInWatchlist = isInWatchlist
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let imageName = isInWatchlist ? "checkmark" : "plus"
        watchlistButton.setImage(
            UIImage(systemName: imageName, withConfiguration: config),
            for: .normal
        )
        watchlistButton.accessibilityValue = isInWatchlist ? "Added" : "Not added"
    }
}

// MARK: - WatchTrailerButtonDelegate

extension FeaturedView: WatchTrailerButtonDelegate {
    func didTap() {
        didTapWatchTrailer()
    }
}
