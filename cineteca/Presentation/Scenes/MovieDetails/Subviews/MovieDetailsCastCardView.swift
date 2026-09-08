import UIKit
import Cartography

final class MovieDetailsCastCardView: UIView {

    // MARK: - UI Components

    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .cardBackground
        imageView.layer.cornerRadius = 28
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .textPrimary
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var characterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 9)
        label.textColor = .textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [profileImageView, nameLabel, characterLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
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
        addSubview(contentStack)
    }

    private func setupConstraints() {
        constrainSelf()
        constrainContentStack()
        constrainProfileImageView()
    }

    private func constrainSelf() {
        constrain(self) { view in
            view.width == 66
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, self) { stack, container in
            stack.edges == container.edges
        }
    }

    private func constrainProfileImageView() {
        constrain(profileImageView) { imageView in
            imageView.width == 56
            imageView.height == 56
        }
    }

    // MARK: - Configure

    func configure(viewModel: MovieDetailsModels.CastViewModel) {
        nameLabel.text = viewModel.name
        characterLabel.text = viewModel.character
        profileImageView.loadImage(from: viewModel.profileURL)
    }
}
