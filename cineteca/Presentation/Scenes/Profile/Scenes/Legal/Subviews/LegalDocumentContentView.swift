import UIKit
import Cartography

protocol LegalDocumentContentViewDelegate: AnyObject {
    func didTapBack()
}

final class LegalDocumentContentView: UIView {

    // MARK: - Properties

    weak var delegate: LegalDocumentContentViewDelegate?
    private let content: LegalDocumentContent

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

    private lazy var headerView: BackNavigationHeaderView = {
        BackNavigationHeaderView(title: content.title)
    }()
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
        self.content = content
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

// MARK: - BackNavigationHeaderViewDelegate

extension LegalDocumentContentView: BackNavigationHeaderViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }
}
