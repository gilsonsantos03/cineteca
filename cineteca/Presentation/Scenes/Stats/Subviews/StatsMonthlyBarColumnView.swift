import UIKit
import Cartography

final class StatsMonthlyBarColumnView: UIView {

    // MARK: - Properties

    private var relativeHeight: Double = 0
    private var barHeightConstraint: NSLayoutConstraint?

    // MARK: - UI Components

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 9, weight: .semibold)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    private lazy var barView: UIView = {
        let view = UIView()
        view.backgroundColor = .accentYellow
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        updateBarHeight()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(valueLabel)
        addSubview(barView)
    }

    private func setupConstraints() {
        constrainValueLabel()
        constrainBarView()
    }

    private func constrainValueLabel() {
        constrain(valueLabel, self) { label, superview in
            label.top == superview.top
            label.left == superview.left
            label.right == superview.right
            label.height == 14
        }
    }

    private func constrainBarView() {
        constrain(barView, valueLabel, self) { bar, value, superview in
            bar.left == superview.left
            bar.right == superview.right
            bar.bottom == superview.bottom
            bar.top >= value.bottom + 4
        }
        let constraint = barView.heightAnchor.constraint(equalToConstant: 0)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        barHeightConstraint = constraint
    }

    // MARK: - Configure

    func configure(viewModel: StatsModels.MonthlyBarViewModel) {
        valueLabel.text = viewModel.valueText
        relativeHeight = viewModel.relativeHeight
        setNeedsLayout()
    }

    // MARK: - Helpers

    private func updateBarHeight() {
        let availableHeight = bounds.height - 18
        guard availableHeight > 0 else { return }
        barHeightConstraint?.constant = availableHeight * CGFloat(max(relativeHeight, 0.08))
    }
}
