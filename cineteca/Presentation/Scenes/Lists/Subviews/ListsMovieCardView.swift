import UIKit
import Cartography

protocol ListsMovieCardViewDelegate: AnyObject {
    func didSelectMovie(id movieId: Int)
    func didRequestRemoveMovie(id movieId: Int)
}

final class ListsMovieCardView: UIView {

    // MARK: - Properties

    weak var delegate: ListsMovieCardViewDelegate?
    private var movieId: Int?

    // MARK: - UI Components

    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .appBackground
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textPrimary
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var metadataLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .textSecondary
        label.numberOfLines = 1
        return label
    }()

    private lazy var genresStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .accentYellow
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var ratingScaleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.ListsScene.Card.ratingScale
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textSecondary
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var ratingStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ratingLabel, ratingScaleLabel])
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .lastBaseline
        stack.setContentHuggingPriority(.required, for: .horizontal)
        stack.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stack
    }()

    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        button.setImage(UIImage(systemName: "trash", withConfiguration: configuration), for: .normal)
        button.tintColor = .destructiveRed
        button.accessibilityLabel = Strings.ListsScene.Card.removeAccessibilityLabel
        button.addTarget(self, action: #selector(didTapRemove), for: .touchUpInside)
        return button
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
        layer.cornerRadius = 20
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCard)))
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(posterImageView)
        addSubview(titleLabel)
        addSubview(metadataLabel)
        addSubview(genresStack)
        addSubview(ratingStack)
        addSubview(removeButton)
    }

    private func setupConstraints() {
        constrainPosterImageView()
        constrainTitleLabel()
        constrainMetadataLabel()
        constrainGenresStack()
        constrainRatingStack()
        constrainRemoveButton()
    }

    private func constrainPosterImageView() {
        constrain(posterImageView, self) { imageView, container in
            imageView.top == container.top + 12
            imageView.left == container.left + 12
            imageView.bottom == container.bottom - 12
            imageView.width == 112
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, posterImageView, removeButton) { label, imageView, button in
            label.top == imageView.top
            label.left == imageView.right + 14
            label.right == button.left - 8
            label.height == 42
        }
    }

    private func constrainMetadataLabel() {
        constrain(metadataLabel, titleLabel, removeButton) { label, title, button in
            label.top == title.bottom + 4
            label.left == title.left
            label.right == button.left - 8
        }
    }

    private func constrainGenresStack() {
        constrain(genresStack, metadataLabel, removeButton) { stack, metadata, button in
            stack.top == metadata.bottom + 8
            stack.left == metadata.left
            stack.right <= button.left - 8
            stack.height == 26
        }
    }

    private func constrainRatingStack() {
        constrain(ratingStack, posterImageView, self) { stack, imageView, container in
            stack.left == imageView.right + 14
            stack.bottom == imageView.bottom
        }
    }

    private func constrainRemoveButton() {
        constrain(removeButton, self) { button, container in
            button.top == container.top + 14
            button.right == container.right - 14
            button.width == 18
            button.height == 18
        }
    }

    // MARK: - Configure

    func configure(viewModel: ListsModels.MovieCardViewModel) {
        movieId = viewModel.movieId
        posterImageView.loadImage(from: viewModel.posterURL)
        titleLabel.text = viewModel.title
        metadataLabel.text = viewModel.metadata
        ratingLabel.text = viewModel.rating
        ratingStack.isHidden = viewModel.rating == nil

        genresStack.arrangedSubviews.forEach {
            genresStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        viewModel.genres.prefix(2).forEach { genre in
            genresStack.addArrangedSubview(makeGenreLabel(title: genre))
        }
    }

    // MARK: - Actions

    @objc private func didTapCard() {
        guard let movieId else { return }
        delegate?.didSelectMovie(id: movieId)
    }

    @objc private func didTapRemove() {
        guard let movieId else { return }
        delegate?.didRequestRemoveMovie(id: movieId)
    }

    // MARK: - Helpers

    private func makeGenreLabel(title: String) -> UILabel {
        let label = PaddingLabel(insets: UIEdgeInsets(top: 4, left: 9, bottom: 4, right: 9))
        label.text = title
        label.font = .systemFont(ofSize: 11)
        label.textColor = .textSecondary
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.backgroundColor = .appBackground
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }
}

private final class PaddingLabel: UILabel {
    private let insets: UIEdgeInsets

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { nil }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}
