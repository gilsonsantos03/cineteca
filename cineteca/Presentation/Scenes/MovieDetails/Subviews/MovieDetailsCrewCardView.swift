import UIKit
import Cartography

final class MovieDetailsCrewCardView: UIView {

    // MARK: - UI Components

    private lazy var roleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .textPrimary
        label.numberOfLines = 2
        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [roleLabel, nameLabel])
        stack.axis = .vertical
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
        backgroundColor = .cardBackground
        layer.cornerRadius = 10
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(contentStack)
    }

    private func setupConstraints() {
        constrainSelf()
        constrainContentStack()
    }

    private func constrainSelf() {
        constrain(self) { view in
            view.height == 64
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, self) { stack, container in
            stack.top == container.top + 10
            stack.bottom == container.bottom - 10
            stack.left == container.left + 10
            stack.right == container.right - 10
        }
    }

    // MARK: - Configure

    func configure(viewModel: MovieDetailsModels.CrewViewModel) {
        roleLabel.text = viewModel.role
        nameLabel.text = viewModel.name
    }
}
