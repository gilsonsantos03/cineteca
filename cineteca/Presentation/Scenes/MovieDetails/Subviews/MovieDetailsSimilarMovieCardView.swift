import UIKit
import Cartography

protocol MovieDetailsSimilarMovieCardViewDelegate: AnyObject {
    func didSelectMovie(id movieId: Int)
}

final class MovieDetailsSimilarMovieCardView: UIButton {

    // MARK: - Properties

    weak var delegate: MovieDetailsSimilarMovieCardViewDelegate?
    private var movieId: Int?

    // MARK: - UI Components

    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .cardBackground
        imageView.layer.cornerRadius = 9
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private lazy var movieTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.isUserInteractionEnabled = false
        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [posterImageView, movieTitleLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.isUserInteractionEnabled = false
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
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    private func setupSubviews() {
        addSubview(contentStack)
    }

    private func setupConstraints() {
        constrainContentStack()
        constrainPosterImageView()
    }

    private func constrainContentStack() {
        constrain(contentStack, self) { stack, button in
            stack.edges == button.edges
        }
    }

    private func constrainPosterImageView() {
        constrain(posterImageView) { imageView in
            imageView.width == 105
            imageView.height == 150
        }
    }

    // MARK: - Configure

    func configure(viewModel: MovieDetailsModels.SimilarMovieViewModel) {
        movieId = viewModel.id
        movieTitleLabel.text = viewModel.title
        posterImageView.loadImage(from: viewModel.posterURL)
    }

    // MARK: - Actions

    @objc private func didTap() {
        guard let movieId else { return }
        delegate?.didSelectMovie(id: movieId)
    }
}
