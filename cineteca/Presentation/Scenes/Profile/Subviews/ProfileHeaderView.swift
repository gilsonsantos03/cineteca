import UIKit
import Cartography

protocol ProfileHeaderViewDelegate: AnyObject {
    func didTapEdit()
}

final class ProfileHeaderView: UIView {

    // MARK: - Properties

    weak var delegate: ProfileHeaderViewDelegate?

    // MARK: - UI Components

    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        button.setImage(UIImage(systemName: "pencil", withConfiguration: config), for: .normal)
        button.tintColor = .textPrimary
        button.backgroundColor = .surfaceOverlay
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        return button
    }()

    private lazy var avatarContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 44
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.accentYellow.cgColor
        view.clipsToBounds = true
        return view
    }()

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .cardBackground
        imageView.tintColor = .textSecondary
        return imageView
    }()

    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var memberSinceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .textSecondary
        label.textAlignment = .center
        return label
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
        addSubview(editButton)
        addSubview(avatarContainerView)
        avatarContainerView.addSubview(avatarImageView)
        addSubview(usernameLabel)
        addSubview(memberSinceLabel)
    }

    private func setupConstraints() {
        constrainEditButton()
        constrainAvatarContainerView()
        constrainAvatarImageView()
        constrainUsernameLabel()
        constrainMemberSinceLabel()
    }

    private func constrainEditButton() {
        constrain(editButton, self) { button, superview in
            button.top == superview.top
            button.right == superview.right - 20
            button.width == 36
            button.height == 36
        }
    }

    private func constrainAvatarContainerView() {
        constrain(avatarContainerView, self) { avatar, superview in
            avatar.top == superview.top + 8
            avatar.centerX == superview.centerX
            avatar.width == 88
            avatar.height == 88
        }
    }

    private func constrainAvatarImageView() {
        constrain(avatarImageView, avatarContainerView) { image, container in
            image.edges == container.edges
        }
    }

    private func constrainUsernameLabel() {
        constrain(usernameLabel, avatarContainerView, self) { label, avatar, superview in
            label.top == avatar.bottom + 12
            label.left == superview.left + 20
            label.right == superview.right - 20
        }
    }

    private func constrainMemberSinceLabel() {
        constrain(memberSinceLabel, usernameLabel, self) { label, username, superview in
            label.top == username.bottom + 4
            label.left == superview.left + 20
            label.right == superview.right - 20
            label.bottom == superview.bottom
        }
    }

    // MARK: - Configure

    func configure(viewModel: ProfileModels.HeaderViewModel) {
        usernameLabel.text = viewModel.username
        memberSinceLabel.text = viewModel.memberSinceText
        if let imageName = viewModel.avatarImageName, let image = UIImage(named: imageName) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: "person.fill")
        }
    }

    // MARK: - Actions

    @objc private func didTapEdit() {
        delegate?.didTapEdit()
    }
}
