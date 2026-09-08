import UIKit
import Cartography

protocol EditProfileHeaderViewDelegate: AnyObject {
    func didTapBack()
}

final class EditProfileHeaderView: UIView {

    // MARK: - Properties

    weak var delegate: EditProfileHeaderViewDelegate?

    // MARK: - UI Components

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

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.EditProfileScene.title
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
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
        addSubview(backButton)
        addSubview(titleLabel)
    }

    private func setupConstraints() {
        constrainBackButton()
        constrainTitleLabel()
    }

    private func constrainBackButton() {
        constrain(backButton, self) { button, superview in
            button.top == superview.top
            button.left == superview.left + 20
            button.width == 36
            button.height == 36
            button.bottom == superview.bottom
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, backButton, self) { label, backButton, superview in
            label.centerX == superview.centerX
            label.centerY == backButton.centerY
            label.left >= backButton.right + 12
            label.right <= superview.right - 20
        }
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        delegate?.didTapBack()
    }
}
