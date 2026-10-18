import UIKit
import Cartography

final class MovieCatalogGridCell: UICollectionViewCell {
    static let reuseId = "MovieCatalogGridCell"

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
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .textPrimary
        label.numberOfLines = 1
        return label
    }()

    private lazy var yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .accentYellow
        return label
    }()

    private lazy var starImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = .accentYellow
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var ratingRow: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [starImageView, ratingLabel])
        stack.axis = .horizontal
        stack.spacing = 3
        stack.alignment = .center
        return stack
    }()

    private lazy var metadataRow: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [yearLabel, UIView(), ratingRow])
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [posterImageView, titleLabel, metadataRow])
        stack.axis = .vertical
        stack.spacing = 5
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
        constrainPosterImageView()
        constrainStarImageView()
    }

    private func constrainContentStack() {
        constrain(contentStack, contentView) { stack, container in
            stack.edges == container.edges
        }
    }

    private func constrainPosterImageView() {
        constrain(posterImageView) { imageView in
            imageView.height == imageView.width * 1.45
        }
    }

    private func constrainStarImageView() {
        constrain(starImageView) { imageView in
            imageView.width == 10
            imageView.height == 10
        }
    }

    // MARK: - Configure

    func configure(viewModel: MovieCatalogModels.MovieCardViewModel) {
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
