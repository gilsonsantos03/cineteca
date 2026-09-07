import UIKit
import Cartography

final class ProfileReviewCardView: UIView {

    // MARK: - UI Components

    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .cardBackground
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private lazy var starRatingView = StarRatingView()

    private lazy var reviewTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .textSecondary
        label.numberOfLines = 2
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .cardBackground
        layer.cornerRadius = 12
        isUserInteractionEnabled = false
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(posterImageView)
        addSubview(titleLabel)
        addSubview(starRatingView)
        addSubview(reviewTextLabel)
    }

    private func setupConstraints() {
        constrainPosterImageView()
        constrainTitleLabel()
        constrainStarRatingView()
        constrainReviewTextLabel()
    }

    private func constrainPosterImageView() {
        constrain(posterImageView, self) { poster, superview in
            poster.top == superview.top + 12
            poster.left == superview.left + 12
            poster.bottom == superview.bottom - 12
            poster.width == 48
            poster.height == 72
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, posterImageView, self) { title, poster, superview in
            title.top == poster.top
            title.left == poster.right + 12
            title.right == superview.right - 12
        }
    }

    private func constrainStarRatingView() {
        constrain(starRatingView, titleLabel) { stars, title in
            stars.top == title.bottom + 4
            stars.left == title.left
            stars.height == 14
        }
    }

    private func constrainReviewTextLabel() {
        constrain(reviewTextLabel, starRatingView, self) { text, stars, superview in
            text.top == stars.bottom + 6
            text.left == stars.left
            text.right == superview.right - 12
        }
    }

    // MARK: - Configure

    func configure(viewModel: ProfileReviewCardViewModel) {
        titleLabel.text = viewModel.title
        reviewTextLabel.text = viewModel.reviewText
        starRatingView.configure(rating: viewModel.rating)
        posterImageView.loadImage(from: viewModel.posterURL)
    }
}
