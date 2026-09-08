import UIKit
import Cartography

protocol EditProfileAvatarViewDelegate: AnyObject {
    func didTapChangePhoto()
}

final class EditProfileAvatarView: UIView {

    // MARK: - Properties

    weak var delegate: EditProfileAvatarViewDelegate?

    // MARK: - UI Components

    private lazy var avatarContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 50
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

    private lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        button.setImage(UIImage(systemName: "camera.fill", withConfiguration: config), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .accentYellow
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapChangePhoto), for: .touchUpInside)
        return button
    }()

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.EditProfileScene.changePhotoHint
        label.font = .systemFont(ofSize: 13)
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
        addSubview(avatarContainerView)
        avatarContainerView.addSubview(avatarImageView)
        addSubview(cameraButton)
        addSubview(hintLabel)
    }

    private func setupConstraints() {
        constrainAvatarContainerView()
        constrainAvatarImageView()
        constrainCameraButton()
        constrainHintLabel()
    }

    private func constrainAvatarContainerView() {
        constrain(avatarContainerView, self) { avatar, superview in
            avatar.top == superview.top
            avatar.centerX == superview.centerX
            avatar.width == 100
            avatar.height == 100
        }
    }

    private func constrainAvatarImageView() {
        constrain(avatarImageView, avatarContainerView) { image, container in
            image.edges == container.edges
        }
    }

    private func constrainCameraButton() {
        constrain(cameraButton, avatarContainerView) { button, avatar in
            button.right == avatar.right + 2
            button.bottom == avatar.bottom + 2
            button.width == 32
            button.height == 32
        }
    }

    private func constrainHintLabel() {
        constrain(hintLabel, avatarContainerView, self) { label, avatar, superview in
            label.top == avatar.bottom + 12
            label.left == superview.left + 20
            label.right == superview.right - 20
            label.bottom == superview.bottom
        }
    }

    // MARK: - Configure

    func configure(avatarImageName: String?) {
        if let imageName = avatarImageName, let image = UIImage(named: imageName) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: "person.fill")
        }
    }

    // MARK: - Actions

    @objc private func didTapChangePhoto() {
        delegate?.didTapChangePhoto()
    }
}
