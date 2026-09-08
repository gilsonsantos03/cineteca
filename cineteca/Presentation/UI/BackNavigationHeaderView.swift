import UIKit
import Cartography

protocol BackNavigationHeaderViewDelegate: AnyObject {
    func didTapBack()
}

final class BackNavigationHeaderView: UIView {

    // MARK: - Properties

    weak var delegate: BackNavigationHeaderViewDelegate?

    // MARK: - UI Components

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .textPrimary
        button.backgroundColor = .surfaceOverlay
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        return label
    }()

    // MARK: - Initialization

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
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
