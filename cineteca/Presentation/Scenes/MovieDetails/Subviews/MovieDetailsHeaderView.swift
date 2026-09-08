import UIKit
import Cartography

protocol MovieDetailsHeaderViewDelegate: AnyObject {
    func didTapBack()
}

final class MovieDetailsHeaderView: UIView {

    // MARK: - Properties

    weak var delegate: MovieDetailsHeaderViewDelegate?

    // MARK: - UI Components

    private lazy var backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.appBackground.cgColor]
        gradient.locations = [0.3, 1]
        return gradient
    }()

    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private lazy var metadataLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var certificationBadge: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        container.layer.cornerRadius = 4
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        container.isHidden = true
        container.isAccessibilityElement = true
        return container
    }()

    private lazy var certificationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        return label
    }()

    private lazy var metadataStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [metadataLabel, certificationBadge])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private lazy var genresStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        return stack
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = backdropImageView.bounds
    }

    // MARK: - Setup

    private func setup() {
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        backdropImageView.layer.addSublayer(gradientLayer)
        addSubview(backdropImageView)
        addSubview(posterImageView)
        addSubview(titleLabel)
        addSubview(metadataStack)
        certificationBadge.addSubview(certificationLabel)
        addSubview(genresStack)
        addSubview(backButton)
    }

    private func setupConstraints() {
        constrainBackdropImageView()
        constrainBackButton()
        constrainPosterImageView()
        constrainTitleLabel()
        constrainMetadataStack()
        constrainCertificationBadge()
        constrainGenresStack()
    }

    private func constrainBackdropImageView() {
        constrain(backdropImageView, self) { imageView, superview in
            imageView.edges == superview.edges
        }
    }

    private func constrainBackButton() {
        constrain(backButton, self) { button, superview in
            button.top == superview.safeAreaLayoutGuide.top + 8
            button.left == superview.left + 20
            button.width == 36
            button.height == 36
        }
    }

    private func constrainPosterImageView() {
        constrain(posterImageView, self) { imageView, superview in
            imageView.left == superview.left + 20
            imageView.bottom == superview.bottom - 20
            imageView.width == 100
            imageView.height == 150
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, posterImageView) { label, poster in
            label.left == poster.right + 14
        }
        constrain(titleLabel, self) { label, superview in
            label.right == superview.right - 20
        }
        constrain(titleLabel, metadataStack) { label, metadata in
            label.bottom == metadata.top - 7
        }
    }

    private func constrainMetadataStack() {
        constrain(metadataStack, posterImageView) { stack, poster in
            stack.left == poster.right + 14
        }
        constrain(metadataStack, genresStack) { stack, genres in
            stack.bottom == genres.top - 7
        }
    }

    private func constrainCertificationBadge() {
        constrain(certificationLabel, certificationBadge) { label, badge in
            label.top == badge.top + 3
            label.bottom == badge.bottom - 3
            label.left == badge.left + 6
            label.right == badge.right - 6
        }
    }

    private func constrainGenresStack() {
        constrain(genresStack, posterImageView) { stack, poster in
            stack.left == poster.right + 14
            stack.bottom == poster.bottom
        }
    }

    // MARK: - Configure

    func configure(
        title: String,
        metadata: String,
        certification: String?,
        genres: [String],
        posterURL: URL?,
        backdropURL: URL?
    ) {
        titleLabel.text = title
        metadataLabel.text = metadata
        if let certification, !certification.isEmpty {
            certificationLabel.text = certification
            certificationBadge.isHidden = false
            certificationBadge.accessibilityLabel = "\(Strings.MovieDetailsScene.Certification.accessibilityLabel): \(certification)"
        } else {
            certificationBadge.isHidden = true
        }
        posterImageView.loadImage(from: posterURL)
        backdropImageView.loadImage(from: backdropURL)
        genresStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        genres.forEach { genresStack.addArrangedSubview(makeGenreChip($0)) }
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        delegate?.didTapBack()
    }

    // MARK: - Helpers

    private func makeGenreChip(_ text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        container.layer.cornerRadius = 10

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .white

        container.addSubview(label)
        constrain(label, container) { label, container in
            label.top == container.top + 4
            label.bottom == container.bottom - 4
            label.left == container.left + 8
            label.right == container.right - 8
        }
        return container
    }
}
