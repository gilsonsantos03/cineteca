import UIKit
import Cartography

final class LegalDocumentSectionView: UIView {

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .textPrimary
        label.numberOfLines = 0
        return label
    }()

    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    // MARK: - Initialization

    init(section: LegalDocumentSection) {
        super.init(frame: .zero)
        titleLabel.text = section.title
        bodyLabel.text = section.body
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
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
            stack.edges == superview.edges
        }
    }
}
