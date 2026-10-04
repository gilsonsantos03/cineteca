import UIKit
import Cartography

final class StatsTopPersonView: UIView {

    // MARK: - UI Components

    private lazy var sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 14
        return view
    }()

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .surfaceOverlay
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.accentYellow.cgColor
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        avatarImageView.layer.borderColor = UIColor.accentYellow.cgColor
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(sectionTitleLabel)
        addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(textStack)
    }

    private func setupConstraints() {
        constrainSectionTitleLabel()
        constrainCardView()
        constrainAvatarImageView()
        constrainTextStack()
    }

    private func constrainSectionTitleLabel() {
        constrain(sectionTitleLabel, self) { label, superview in
            label.top == superview.top
            label.left == superview.left + 20
            label.right == superview.right - 20
        }
    }

    private func constrainCardView() {
        constrain(cardView, sectionTitleLabel, self) { card, title, superview in
            card.top == title.bottom + 12
            card.left == superview.left + 20
            card.right == superview.right - 20
            card.bottom == superview.bottom
            card.height == 80
        }
    }

    private func constrainAvatarImageView() {
        constrain(avatarImageView, cardView) { imageView, card in
            imageView.left == card.left + 16
            imageView.centerY == card.centerY
            imageView.width == 48
            imageView.height == 48
        }
    }

    private func constrainTextStack() {
        constrain(textStack, avatarImageView, cardView) { stack, avatar, card in
            stack.left == avatar.right + 14
            stack.right == card.right - 16
            stack.centerY == card.centerY
        }
    }

    // MARK: - Configure

    func configure(viewModel: StatsModels.TopPersonViewModel) {
        sectionTitleLabel.text = viewModel.sectionTitle
        nameLabel.text = viewModel.name
        subtitleLabel.text = viewModel.subtitle
        avatarImageView.loadImage(from: viewModel.profileURL)
    }
}
