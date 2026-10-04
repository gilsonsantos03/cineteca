import UIKit
import Cartography

protocol AppearanceThemeSectionViewDelegate: AnyObject {
    func didSelectTheme(_ theme: AppTheme)
}

final class AppearanceThemeSectionView: UIView {

    // MARK: - Properties

    weak var delegate: AppearanceThemeSectionViewDelegate?

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

    func configure(viewModel: AppearanceModels.ThemeSectionViewModel) {
        titleLabel.text = viewModel.title
        rowsStack.arrangedSubviews.forEach {
            rowsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for (index, option) in viewModel.options.enumerated() {
            let rowView = AppearanceThemeRowView(
                title: option.title,
                isSelected: option.isSelected,
                showsSeparator: index < viewModel.options.count - 1
            )
            rowView.onTap = { [weak self] in
                self?.delegate?.didSelectTheme(option.theme)
            }
            rowsStack.addArrangedSubview(rowView)
        }
    }
}

private final class AppearanceThemeRowView: UIView {
    var onTap: (() -> Void)?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var checkmarkImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let imageView = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: config))
        imageView.tintColor = .accentYellow
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    init(title: String, isSelected: Bool, showsSeparator: Bool) {
        super.init(frame: .zero)
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
        separatorView.isHidden = !showsSeparator
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(checkmarkImageView)
        addSubview(separatorView)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    private func setupConstraints() {
        constrainSelf()
        constrainTitleLabel()
        constrainCheckmarkImageView()
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

    private func constrainCheckmarkImageView() {
        constrain(checkmarkImageView, self) { checkmark, superview in
            checkmark.centerY == superview.centerY
            checkmark.right == superview.right - 16
            checkmark.width == 16
            checkmark.height == 16
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

    @objc private func handleTap() {
        onTap?()
    }
}
