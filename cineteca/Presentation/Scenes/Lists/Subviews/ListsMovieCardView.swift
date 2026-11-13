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
    private var isRemoving = false
    private var panStartX: CGFloat = 0

    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()

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
        backgroundColor = .appBackground
        layer.cornerRadius = 20
        clipsToBounds = true
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        contentContainerView.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanCard(_:)))
        panGesture.delegate = self
        contentContainerView.addGestureRecognizer(panGesture)
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(contentContainerView)
        contentContainerView.addSubview(posterImageView)
        contentContainerView.addSubview(titleLabel)
        contentContainerView.addSubview(metadataLabel)
        contentContainerView.addSubview(genresStack)
        contentContainerView.addSubview(ratingStack)
        contentContainerView.addSubview(removeButton)
    }

    private func setupConstraints() {
        constrain(contentContainerView, self) { content, container in
            content.edges == container.edges
        }
        constrainPosterImageView()
        constrainTitleLabel()
        constrainMetadataLabel()
        constrainGenresStack()
        constrainRatingStack()
        constrainRemoveButton()
    }

    private func constrainPosterImageView() {
        constrain(posterImageView, contentContainerView) { imageView, container in
            imageView.top == container.top + 12
            imageView.leading == container.leading + 12
            imageView.bottom == container.bottom - 12
            imageView.width == 112
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, posterImageView, removeButton) { label, imageView, button in
            label.top == imageView.top
            label.leading == imageView.trailing + 14
            label.trailing == button.leading - 8
            label.height == 42
        }
    }

    private func constrainMetadataLabel() {
        constrain(metadataLabel, titleLabel, removeButton) { label, title, button in
            label.top == title.bottom + 4
            label.leading == title.leading
            label.trailing == button.leading - 8
        }
    }

    private func constrainGenresStack() {
        constrain(genresStack, metadataLabel, removeButton) { stack, metadata, button in
            stack.top == metadata.bottom + 8
            stack.leading == metadata.leading
            stack.trailing <= button.leading - 8
            stack.height == 26
        }
    }

    private func constrainRatingStack() {
        constrain(ratingStack, posterImageView, contentContainerView) { stack, imageView, container in
            stack.leading == imageView.trailing + 14
            stack.bottom == imageView.bottom
        }
    }

    private func constrainRemoveButton() {
        constrain(removeButton, contentContainerView) { button, container in
            button.top == container.top + 14
            button.trailing == container.trailing - 14
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

    @objc private func didPanCard(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        switch gesture.state {
        case .began:
            panStartX = contentContainerView.transform.tx
        case .changed:
            let x = min(0, panStartX + translation.x)
            let progress = min(abs(x) / max(bounds.width, 1), 1)
            contentContainerView.transform = CGAffineTransform(translationX: x, y: 0)
            contentContainerView.alpha = 1 - progress * 0.25
        case .ended, .cancelled:
            let shouldRemove = contentContainerView.transform.tx <= -bounds.width * 0.35
            if shouldRemove {
                removeAfterSwipe()
            } else {
                restoreAfterSwipe()
            }
        default:
            break
        }
    }

    private func removeAfterSwipe() {
        guard !isRemoving, movieId != nil else { return }
        isRemoving = true
        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                self.contentContainerView.transform = CGAffineTransform(
                    translationX: -self.bounds.width,
                    y: 0
                )
                self.contentContainerView.alpha = 0
            },
            completion: { [weak self] _ in
                self?.didTapRemove()
            }
        )
    }

    private func restoreAfterSwipe() {
        UIView.animate(withDuration: 0.2) {
            self.contentContainerView.transform = .identity
            self.contentContainerView.alpha = 1
        }
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

extension ListsMovieCardView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = panGesture.velocity(in: self)
        return abs(velocity.x) > abs(velocity.y) && velocity.x < 0
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
