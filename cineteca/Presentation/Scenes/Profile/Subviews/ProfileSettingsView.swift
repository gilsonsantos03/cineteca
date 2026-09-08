import UIKit
import Cartography

protocol ProfileSettingsViewDelegate: AnyObject {
    func didSelectSetting(_ setting: ProfileSetting)
}

final class ProfileSettingsView: UIView {

    // MARK: - Properties

    weak var delegate: ProfileSettingsViewDelegate?

    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var rowsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
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
        containerView.addSubview(rowsStack)
    }

    private func setupConstraints() {
        constrainContainerView()
        constrainRowsStack()
    }

    private func constrainContainerView() {
        constrain(containerView, self) { container, superview in
            container.top == superview.top
            container.left == superview.left + 20
            container.right == superview.right - 20
            container.bottom == superview.bottom
        }
    }

    private func constrainRowsStack() {
        constrain(rowsStack, containerView) { stack, container in
            stack.top == container.top
            stack.left == container.left
            stack.right == container.right
            stack.bottom == container.bottom
        }
    }

    // MARK: - Configure

    func configure(viewModel: ProfileSettingsViewModel) {
        rowsStack.arrangedSubviews.forEach {
            rowsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for (index, row) in viewModel.rows.enumerated() {
            let rowView = ProfileSettingsRowView()
            rowView.configure(
                title: row.title,
                showsSeparator: index < viewModel.rows.count - 1
            )
            rowView.onTap = { [weak self] in
                self?.delegate?.didSelectSetting(row.setting)
            }
            rowsStack.addArrangedSubview(rowView)
        }
    }
}

private final class ProfileSettingsRowView: UIView {

    var onTap: (() -> Void)?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var chevronImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: config))
        imageView.tintColor = .textSecondary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) { nil }

    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(chevronImageView)
        addSubview(separatorView)
    }

    private func setupConstraints() {
        constrainSelf()
        constrainTitleLabel()
        constrainChevronImageView()
        constrainSeparatorView()
    }

    private func constrainSelf() {
        constrain(self) { view in
            view.height == 52
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, self) { label, superview in
            label.centerY == superview.centerY
            label.left == superview.left + 16
        }
    }

    private func constrainChevronImageView() {
        constrain(chevronImageView, self) { chevron, superview in
            chevron.centerY == superview.centerY
            chevron.right == superview.right - 16
            chevron.width == 10
            chevron.height == 16
        }
    }

    private func constrainSeparatorView() {
        constrain(separatorView, self) { separator, superview in
            separator.left == superview.left + 16
            separator.right == superview.right
            separator.bottom == superview.bottom
            separator.height == 1
        }
    }

    func configure(title: String, showsSeparator: Bool) {
        titleLabel.text = title
        separatorView.isHidden = !showsSeparator
    }

    @objc private func handleTap() {
        onTap?()
    }
}
