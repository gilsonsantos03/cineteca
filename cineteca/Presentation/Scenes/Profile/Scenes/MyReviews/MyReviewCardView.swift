import UIKit
import Cartography

protocol MyReviewCardViewDelegate: AnyObject {
    func didSelectReview(_ review: MyReviewsModels.ReviewCardViewModel)
}

final class MyReviewCardView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: MyReviewCardViewDelegate?

    private var review: MyReviewsModels.ReviewCardViewModel?

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
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var metadataLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .textSecondary
        label.numberOfLines = 1
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
        stack.distribution = .fill
        stack.spacing = 2
        stack.setContentHuggingPriority(.required, for: .horizontal)
        stack.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stack
    }()

    private lazy var movieInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, metadataLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 6
        return stack
    }()

    private lazy var reviewTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        return label
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .textSecondary
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
        layer.cornerRadius = 18
        isUserInteractionEnabled = true
        setupSubviews()
        setupConstraints()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    private func setupSubviews() {
        addSubview(posterImageView)
        addSubview(ratingStack)
        addSubview(movieInfoStack)
        addSubview(reviewTextLabel)
        addSubview(separatorView)
        addSubview(dateLabel)
    }

    private func setupConstraints() {
        constrainPosterImageView()
        constrainRatingStack()
        constrainTitleLabel()
        constrainReviewTextLabel()
        constrainSeparatorView()
        constrainDateLabel()
    }

    private func constrainPosterImageView() {
        constrain(posterImageView, self) { poster, superview in
            poster.top == superview.top + 16
            poster.left == superview.left + 16
            poster.width == 60
            poster.height == 60
        }
    }

    private func constrainRatingStack() {
        constrain(ratingStack, posterImageView, self) { rating, poster, superview in
            rating.centerY == poster.centerY
            rating.right == superview.right - 16
        }
    }

    private func constrainTitleLabel() {
        constrain(movieInfoStack, posterImageView, ratingStack) { info, poster, rating in
            info.centerY == poster.centerY
            info.left == poster.right + 14
            info.right == rating.left - 8
        }
    }

    private func constrainReviewTextLabel() {
        constrain(reviewTextLabel, posterImageView, self) { text, poster, superview in
            text.top == poster.bottom + 16
            text.left == superview.left + 16
            text.right == superview.right - 16
        }
    }

    private func constrainSeparatorView() {
        constrain(separatorView, reviewTextLabel, self) { separator, text, superview in
            separator.top == text.bottom + 16
            separator.left == superview.left + 16
            separator.right == superview.right - 16
            separator.height == 1
        }
    }

    private func constrainDateLabel() {
        constrain(dateLabel, separatorView, self) { date, separator, superview in
            date.top == separator.bottom + 14
            date.left == superview.left + 16
            date.bottom == superview.bottom - 16
        }
    }

    // MARK: - Configure

    func configure(viewModel: MyReviewsModels.ReviewCardViewModel) {
        review = viewModel
        posterImageView.loadImage(from: viewModel.posterURL)
        titleLabel.text = viewModel.title
        metadataLabel.text = viewModel.metadata
        metadataLabel.isHidden = viewModel.metadata.isEmpty
        ratingValueLabel.text = viewModel.rating == viewModel.rating.rounded()
            ? String(format: "%.0f", viewModel.rating)
            : String(format: "%.1f", viewModel.rating)
        let hasComment = !viewModel.reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        reviewTextLabel.text = hasComment
            ? viewModel.reviewText
            : Strings.MyReviewsScene.noComment
        reviewTextLabel.font = hasComment
            ? .systemFont(ofSize: 15)
            : .italicSystemFont(ofSize: 15)
        dateLabel.text = viewModel.dateText
        dateLabel.isHidden = viewModel.dateText.isEmpty
    }

    // MARK: - Actions

    @objc private func didTap() {
        guard let review else { return }
        delegate?.didSelectReview(review)
    }
}
