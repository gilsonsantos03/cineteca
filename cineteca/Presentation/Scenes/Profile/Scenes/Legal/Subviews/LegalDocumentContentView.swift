import UIKit
import Cartography

protocol LegalDocumentContentViewDelegate: AnyObject {
    func didTapBack()
}

final class LegalDocumentContentView: UIView {

    // MARK: - Properties

    weak var delegate: LegalDocumentContentViewDelegate?

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .appBackground
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    private let headerView: BackNavigationHeaderView
    private lazy var lastUpdatedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        return label
    }()

    private lazy var sectionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()

    // MARK: - Initialization

    init(content: LegalDocumentContent) {
        self.headerView = BackNavigationHeaderView(title: content.title)
        super.init(frame: .zero)
        lastUpdatedLabel.text = content.lastUpdated
        content.sections.forEach { section in
            sectionsStack.addArrangedSubview(LegalDocumentSectionView(section: section))
        }
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        headerView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(lastUpdatedLabel)
        contentStack.addArrangedSubview(sectionsStack)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
    }

    private func setupConstraints() {
        constrainScrollView()
        constrainContentStack()
    }

    private func constrainScrollView() {
        constrain(scrollView, self) { scroll, superview in
            scroll.top == superview.safeAreaLayoutGuide.top + 8
            scroll.bottom == superview.bottom
            scroll.left == superview.left
            scroll.right == superview.right
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView) { stack, scroll in
            stack.top == scroll.top
            stack.left == scroll.left + 20
            stack.right == scroll.right - 20
            stack.bottom == scroll.bottom
            stack.width == scroll.width - 40
        }
    }

    // MARK: - Helpers

    private func makeSpacer(height: CGFloat) -> UIView {
        let view = UIView()
        constrainSpacer(view, height: height)
        return view
    }

    private func constrainSpacer(_ spacer: UIView, height: CGFloat) {
        constrain(spacer) { view in
            view.height == height
        }
    }
}

extension LegalDocumentContentView: BackNavigationHeaderViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }
}

private final class LegalDocumentSectionView: UIView {

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
