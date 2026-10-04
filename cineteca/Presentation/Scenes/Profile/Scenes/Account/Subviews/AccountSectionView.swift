import UIKit
import Cartography

protocol AccountSectionViewDelegate: AnyObject {
    func didSelectRow(action: AccountModels.RowAction)
}

final class AccountSectionView: UIView {

    // MARK: - Properties

    weak var delegate: AccountSectionViewDelegate?

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .textSecondary
        return label
    }()

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
        addSubview(titleLabel)
        addSubview(containerView)
        containerView.addSubview(rowsStack)
    }

    private func setupConstraints() {
        constrainTitleLabel()
        constrainContainerView()
        constrainRowsStack()
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, self) { label, superview in
            label.top == superview.top
            label.left == superview.left
            label.right == superview.right
        }
    }

    private func constrainContainerView() {
        constrain(containerView, titleLabel, self) { container, title, superview in
            container.top == title.bottom + 8
            container.left == superview.left
            container.right == superview.right
            container.bottom == superview.bottom
        }
    }

    private func constrainRowsStack() {
        constrain(rowsStack, containerView) { stack, container in
            stack.edges == container.edges
        }
    }

    // MARK: - Configure

    func configure(viewModel: AccountModels.SectionViewModel) {
        titleLabel.text = viewModel.title
        rowsStack.arrangedSubviews.forEach {
            rowsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for (index, row) in viewModel.rows.enumerated() {
            let showsSeparator = index < viewModel.rows.count - 1
            let rowView = makeRowView(for: row, showsSeparator: showsSeparator)
            rowsStack.addArrangedSubview(rowView)
        }
    }

    // MARK: - Helpers

    private func makeRowView(for row: AccountModels.RowViewModel, showsSeparator: Bool) -> UIView {
        switch row {
        case let .value(title, value):
            return AccountValueRowView(title: title, value: value, showsSeparator: showsSeparator)
        case let .navigation(title, action):
            let rowView = AccountNavigationRowView(title: title, showsSeparator: showsSeparator)
            rowView.onTap = { [weak self] in
                self?.delegate?.didSelectRow(action: action)
            }
            return rowView
        case let .danger(title, action):
            let rowView = AccountDangerRowView(title: title)
            rowView.onTap = { [weak self] in
                self?.delegate?.didSelectRow(action: action)
            }
            return rowView
        }
    }
}

private final class AccountValueRowView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .textSecondary
        label.textAlignment = .right
        label.numberOfLines = 2
        return label
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    init(title: String, value: String, showsSeparator: Bool) {
        super.init(frame: .zero)
        titleLabel.text = title
        valueLabel.text = value
        separatorView.isHidden = !showsSeparator
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(separatorView)
        constrain(self) { view in view.height >= 52 }
        constrain(titleLabel, self) { label, superview in
            label.centerY == superview.centerY
            label.left == superview.left + 16
        }
        constrain(valueLabel, titleLabel, self) { value, title, superview in
            value.centerY == superview.centerY
            value.left == title.right + 12
            value.right == superview.right - 16
        }
        constrain(separatorView, self) { separator, superview in
            separator.left == superview.left + 16
            separator.right == superview.right
            separator.bottom == superview.bottom
            separator.height == 1
        }
    }
}

private final class AccountNavigationRowView: UIView {
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

    init(title: String, showsSeparator: Bool) {
        super.init(frame: .zero)
        titleLabel.text = title
        separatorView.isHidden = !showsSeparator
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        addSubview(titleLabel)
        addSubview(chevronImageView)
        addSubview(separatorView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        constrain(self) { view in view.height == 52 }
        constrain(titleLabel, self) { label, superview in
            label.centerY == superview.centerY
            label.left == superview.left + 16
        }
        constrain(chevronImageView, self) { chevron, superview in
            chevron.centerY == superview.centerY
            chevron.right == superview.right - 16
            chevron.width == 10
            chevron.height == 16
        }
        constrain(separatorView, self) { separator, superview in
            separator.left == superview.left + 16
            separator.right == superview.right
            separator.bottom == superview.bottom
            separator.height == 1
        }
    }

    @objc private func handleTap() {
        onTap?()
    }
}

private final class AccountDangerRowView: UIView {
    var onTap: (() -> Void)?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(red: 0.95, green: 0.28, blue: 0.28, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        addSubview(titleLabel)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        constrain(self) { view in view.height == 52 }
        constrain(titleLabel, self) { label, superview in
            label.center == superview.center
        }
    }

    @objc private func handleTap() {
        onTap?()
    }
}
