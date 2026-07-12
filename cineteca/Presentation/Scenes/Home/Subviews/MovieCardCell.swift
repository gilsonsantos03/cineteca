import UIKit
import Cartography

final class MovieCardCell: UICollectionViewCell {
    static let reuseId = "MovieCardCell"

    // MARK: - UI Components

    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .cardBackground
        return imageView
    }()

    private lazy var trendingEmojiLabel: UILabel = {
        let label = UILabel()
        label.text = "🔥"
        label.font = .systemFont(ofSize: 10)
        return label
    }()

    private lazy var trendingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Trending"
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private lazy var trendingRow: UIStackView = {
        let row = UIStackView(arrangedSubviews: [trendingEmojiLabel, trendingTitleLabel])
        row.axis = .horizontal
        row.spacing = 3
        return row
    }()

    private lazy var trendingBadgeView: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        container.layer.cornerRadius = 8
        container.isHidden = true
        return container
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        return label
    }()

    private lazy var starImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = .accentYellow
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var ratingRow: UIStackView = {
        let row = UIStackView(arrangedSubviews: [starImageView, ratingLabel])
        row.axis = .horizontal
        row.spacing = 4
        row.alignment = .center
        return row
    }()

    private lazy var movieInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, ratingRow])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
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
        contentView.addSubview(posterImageView)
        contentView.addSubview(trendingBadgeView)
        trendingBadgeView.addSubview(trendingRow)
        contentView.addSubview(movieInfoStack)
    }

    private func setupConstraints() {
        constrainPosterImageView()
        constrainTrendingBadgeView()
        constrainTrendingRow()
        constrainStarImageView()
        constrainMovieInfoStack()
    }

    private func constrainPosterImageView() {
        constrain(posterImageView, contentView) { imageView, container in
            imageView.top == container.top
            imageView.left == container.left
            imageView.right == container.right
            imageView.height == 170
        }
    }

    private func constrainTrendingBadgeView() {
        constrain(trendingBadgeView, posterImageView) { badge, imageView in
            badge.top == imageView.top + 8
            badge.left == imageView.left + 8
        }
    }

    private func constrainTrendingRow() {
        constrain(trendingRow, trendingBadgeView) { row, container in
            row.top == container.top + 4
            row.bottom == container.bottom - 4
            row.left == container.left + 6
            row.right == container.right - 6
        }
    }

    private func constrainStarImageView() {
        constrain(starImageView) { imageView in
            imageView.width == 12
            imageView.height == 12
        }
    }

    private func constrainMovieInfoStack() {
        constrain(movieInfoStack, posterImageView, contentView) { stack, imageView, container in
            stack.top == imageView.bottom + 6
            stack.left == container.left
            stack.right == container.right
        }
    }

    // MARK: - Configure

    func configure(viewModel: MovieCardViewModel) {
        posterImageView.loadImage(from: viewModel.posterURL)
        titleLabel.text = viewModel.title
        ratingLabel.text = viewModel.rating
        trendingBadgeView.isHidden = !viewModel.isTrending
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
    }
}
