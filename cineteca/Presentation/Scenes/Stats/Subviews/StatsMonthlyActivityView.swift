import UIKit
import Cartography

final class StatsMonthlyActivityView: UIView {

    // MARK: - Properties

    private let chartHeight: CGFloat = 160

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var headerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    private lazy var chartContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 14
        return view
    }()

    private lazy var barsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 4
        return stack
    }()

    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
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
        addSubview(headerStack)
        addSubview(chartContainerView)
        chartContainerView.addSubview(barsStack)
        chartContainerView.addSubview(labelsStack)
    }

    private func setupConstraints() {
        constrainHeaderStack()
        constrainChartContainerView()
        constrainBarsStack()
        constrainLabelsStack()
    }

    private func constrainHeaderStack() {
        constrain(headerStack, self) { stack, superview in
            stack.top == superview.top
            stack.left == superview.left + 20
            stack.right == superview.right - 20
        }
    }

    private func constrainChartContainerView() {
        constrain(chartContainerView, headerStack, self) { chart, header, superview in
            chart.top == header.bottom + 12
            chart.left == superview.left + 20
            chart.right == superview.right - 20
            chart.bottom == superview.bottom
            chart.height == chartHeight + 44
        }
    }

    private func constrainBarsStack() {
        constrain(barsStack, chartContainerView) { stack, chart in
            stack.top == chart.top + 12
            stack.left == chart.left + 12
            stack.right == chart.right - 12
            stack.height == chartHeight
        }
    }

    private func constrainLabelsStack() {
        constrain(labelsStack, barsStack, chartContainerView) { labels, bars, chart in
            labels.top == bars.bottom + 8
            labels.left == bars.left
            labels.right == bars.right
            labels.bottom == chart.bottom - 12
        }
    }

    // MARK: - Configure

    func configure(viewModel: StatsMonthlyActivityViewModel) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        clearStacks()

        viewModel.bars.forEach { bar in
            let column = StatsMonthlyBarColumnView()
            column.configure(viewModel: bar)
            barsStack.addArrangedSubview(column)
            labelsStack.addArrangedSubview(makeMonthLabel(text: bar.monthLabel))
        }
    }

    // MARK: - Helpers

    private func clearStacks() {
        [barsStack, labelsStack].forEach { stack in
            stack.arrangedSubviews.forEach { view in
                stack.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
    }

    private func makeMonthLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .textSecondary
        label.textAlignment = .center
        return label
    }
}
