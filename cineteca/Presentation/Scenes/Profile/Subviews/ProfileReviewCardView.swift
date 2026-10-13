import UIKit
import Cartography

final class ProfileReviewCardView: UIView {

    // MARK: - UI Components

    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .cardBackground
        imageView.layer.cornerRadius = 10
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textPrimary
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var ratingValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .accentYellow
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var ratingScaleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textSecondary
        label.text = Strings.MyReviewsScene.ratingScale
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var ratingStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ratingValueLabel, ratingScaleLabel])
        stack.axis = .horizontal
        stack.alignment = .lastBaseline
        stack.spacing = 2
        stack.setContentHuggingPriority(.required, for: .horizontal)
        stack.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stack
    }()

    private lazy var reviewTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
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
        addSubview(ratingStack)
        addSubview(reviewTextLabel)
    }

    private func setupConstraints() {
        constrainPosterImageView()
        constrainTitleLabel()
        constrainRatingStack()
        constrainReviewTextLabel()
    }

    private func constrainPosterImageView() {
        constrain(posterImageView, self) { poster, superview in
            poster.top == superview.top + 16
            poster.left == superview.left + 16
            poster.bottom <= superview.bottom - 16
            poster.width == 80
            poster.height == 80
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, posterImageView, ratingStack) { title, poster, rating in
            title.centerY == rating.centerY
            title.left == poster.right + 14
            title.right == rating.left - 8
        }
    }

    private func constrainRatingStack() {
        constrain(ratingStack, posterImageView, self) { rating, poster, superview in
            rating.centerY == poster.top + 16
            rating.right == superview.right - 16
        }
    }

    private func constrainReviewTextLabel() {
        constrain(reviewTextLabel, posterImageView, self) { text, poster, superview in
            text.centerY == poster.centerY
            text.left == poster.right + 14
            text.right == superview.right - 16
            text.bottom == superview.bottom - 16
        }
    }

    // MARK: - Configure

    func configure(viewModel: ProfileModels.ReviewCardViewModel) {
        titleLabel.text = viewModel.title
        ratingValueLabel.text = viewModel.rating == viewModel.rating.rounded()
            ? String(format: "%.0f", viewModel.rating)
            : String(format: "%.1f", viewModel.rating)
        reviewTextLabel.text = viewModel.reviewText
        posterImageView.loadImage(from: viewModel.posterURL)
    }
}
