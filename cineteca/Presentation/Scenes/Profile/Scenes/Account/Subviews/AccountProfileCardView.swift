import UIKit
import Cartography

final class AccountProfileCardView: UIView {

    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var avatarContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 28
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.accentYellow.cgColor
        view.clipsToBounds = true
        return view
    }()

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .appBackground
        imageView.tintColor = .textSecondary
        return imageView
    }()

    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [usernameLabel, emailLabel])
        stack.axis = .vertical
        stack.spacing = 4
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
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(avatarContainerView)
        avatarContainerView.addSubview(avatarImageView)
        containerView.addSubview(textStack)
    }

    private func setupConstraints() {
        constrainContainerView()
        constrainAvatarContainerView()
        constrainAvatarImageView()
        constrainTextStack()
    }

    private func constrainContainerView() {
        constrain(containerView, self) { container, superview in
            container.edges == superview.edges
        }
    }

    private func constrainAvatarContainerView() {
        constrain(avatarContainerView, containerView) { avatar, container in
            avatar.top == container.top + 16
            avatar.left == container.left + 16
            avatar.bottom == container.bottom - 16
            avatar.width == 56
            avatar.height == 56
        }
    }

    private func constrainAvatarImageView() {
        constrain(avatarImageView, avatarContainerView) { image, container in
            image.edges == container.edges
        }
    }

    private func constrainTextStack() {
        constrain(textStack, avatarContainerView, containerView) { stack, avatar, container in
            stack.centerY == avatar.centerY
            stack.left == avatar.right + 14
            stack.right == container.right - 16
        }
    }

    // MARK: - Configure

    func configure(viewModel: AccountProfileCardViewModel) {
        usernameLabel.text = viewModel.username
        emailLabel.text = viewModel.email
        if let imageName = viewModel.avatarImageName, let image = UIImage(named: imageName) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: "person.fill")
        }
    }
}
