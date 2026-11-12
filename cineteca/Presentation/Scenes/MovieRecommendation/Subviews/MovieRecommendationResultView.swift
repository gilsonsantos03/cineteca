import UIKit
import Cartography

protocol MovieRecommendationResultViewDelegate: AnyObject {
    func didSelectRecommendedMovie()
}

final class MovieRecommendationResultView: UIView {

    // MARK: - Properties

    weak var delegate: MovieRecommendationResultViewDelegate?

    // MARK: - UI Components

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .cardBackground
        imageView.layer.cornerRadius = 18
        imageView.accessibilityLabel = Strings.MovieRecommendationScene.detailsButton
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimary
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    private lazy var metadataLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textSecondary
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var explanationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimary
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    private lazy var detailsButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = Strings.MovieRecommendationScene.detailsButton
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 8,
            bottom: 10,
            trailing: 8
        )
        configuration.baseForegroundColor = .accentYellow

        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(detailsTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "movieRecommendation.detailsButton"
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
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
        setupSubviews()
        setupConstraints()
        setupResultTapTargets()
    }

    private func setupSubviews() {
        addSubview(contentStack)
        contentStack.addArrangedSubview(posterImageView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(metadataLabel)
        contentStack.addArrangedSubview(explanationLabel)
        contentStack.addArrangedSubview(detailsButton)
    }

    private func setupConstraints() {
        constrainContentStack()
        constrainPosterImageView()
    }

    private func constrainContentStack() {
        constrain(contentStack, self) { stack, superview in
            stack.edges == superview.edges
        }
    }

    private func constrainPosterImageView() {
        constrain(posterImageView) { imageView in
            imageView.height == 260
        }
    }

    private func setupResultTapTargets() {
        [posterImageView, titleLabel, metadataLabel, explanationLabel].forEach { view in
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(resultTapped))
            )
        }
    }

    // MARK: - Configure

    func configure(viewModel: MovieRecommendationModels.Generate.ResultViewModel) {
        posterImageView.loadImage(from: viewModel.posterURL)
        posterImageView.accessibilityLabel = viewModel.title
        titleLabel.text = viewModel.title
        metadataLabel.text = "★ \(viewModel.rating)  ·  \(viewModel.year)"
        explanationLabel.text = viewModel.explanation
    }

    // MARK: - Actions

    @objc private func detailsTapped() {
        delegate?.didSelectRecommendedMovie()
    }

    @objc private func resultTapped() {
        delegate?.didSelectRecommendedMovie()
    }
}
