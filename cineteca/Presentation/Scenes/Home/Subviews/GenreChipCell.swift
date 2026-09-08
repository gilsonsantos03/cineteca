import UIKit
import Cartography

final class GenreChipCell: UICollectionViewCell {
    static let reuseId = "GenreChipCell"

    private var isSelectedChip = false

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
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
        contentView.layer.cornerRadius = 18
        contentView.layer.borderWidth = 1
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        contentView.addSubview(titleLabel)
    }

    private func setupConstraints() {
        constrainTitleLabel()
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, contentView) { label, container in
            label.top == container.top + 8
            label.bottom == container.bottom - 8
            label.left == container.left + 16
            label.right == container.right - 16
        }
    }

    // MARK: - Configure

    func configure(title: String, isSelected: Bool) {
        isSelectedChip = isSelected
        titleLabel.text = title
        applyStyle(isSelected: isSelected)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        applyStyle(isSelected: isSelectedChip)
    }

    private func applyStyle(isSelected: Bool) {
        if isSelected {
            contentView.backgroundColor = .accentYellow
            contentView.layer.borderColor = UIColor.accentYellow.cgColor
            titleLabel.textColor = .black
        } else {
            contentView.backgroundColor = .clear
            contentView.layer.borderColor = UIColor.borderSubtle.resolvedColor(with: traitCollection).cgColor
            titleLabel.textColor = .textPrimary
        }
    }
}
