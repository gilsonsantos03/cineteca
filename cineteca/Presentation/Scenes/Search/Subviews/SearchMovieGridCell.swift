import UIKit
import Cartography

final class SearchMovieGridCell: UICollectionViewCell {
    static let reuseId = "SearchMovieGridCell"

    // MARK: - UI Components

    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .cardBackground
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textPrimary
        label.numberOfLines = 2
        return label
    }()

    private lazy var yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .textPrimary
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
        row.spacing = 3
        row.alignment = .center
        return row
    }()

    private lazy var metadataRow: UIStackView = {
        let row = UIStackView(arrangedSubviews: [yearLabel, UIView(), ratingRow])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [posterImageView, titleLabel, metadataRow])
        stack.axis = .vertical
        stack.spacing = 6
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
        contentView.addSubview(contentStack)
    }

    private func setupConstraints() {
        constrainContentStack()
        constrainStarImageView()
    }

    private func constrainContentStack() {
        constrain(contentStack, contentView) { stack, container in
            stack.edges == container.edges
        }
    }

    private func constrainStarImageView() {
        constrain(starImageView) { imageView in
            imageView.width == 11
            imageView.height == 11
        }
    }

    // MARK: - Configure

    func configure(viewModel: SearchModels.MovieGridViewModel) {
        posterImageView.loadImage(from: viewModel.posterURL)
        titleLabel.text = viewModel.title
        yearLabel.text = viewModel.year
        ratingLabel.text = viewModel.rating
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
    }
}
