import UIKit
import Cartography

final class StatsGenreDistributionView: UIView {

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var rowsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        return stack
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, rowsStack])
        stack.axis = .vertical
        stack.spacing = 16
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
        addSubview(contentStack)
    }

    private func setupConstraints() {
        constrainContentStack()
    }

    private func constrainContentStack() {
        constrain(contentStack, self) { stack, superview in
            stack.top == superview.top
            stack.left == superview.left + 20
            stack.right == superview.right - 20
            stack.bottom == superview.bottom
        }
    }

    // MARK: - Configure

    func configure(viewModel: StatsGenreDistributionViewModel) {
        titleLabel.text = viewModel.title
        rowsStack.arrangedSubviews.forEach { view in
            rowsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        viewModel.rows.forEach { row in
            let rowView = StatsGenreRowView()
            rowView.configure(viewModel: row)
            rowsStack.addArrangedSubview(rowView)
        }
    }
}
