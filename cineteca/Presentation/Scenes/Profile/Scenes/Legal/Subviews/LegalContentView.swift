import UIKit
import Cartography

protocol LegalContentViewDelegate: AnyObject {
    func didTapBack()
    func didSelectLink(_ action: LegalLinkAction)
}

final class LegalContentView: UIView {

    // MARK: - Properties

    weak var delegate: LegalContentViewDelegate?

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

    private lazy var headerView = BackNavigationHeaderView(title: Strings.LegalScene.title)
    private lazy var linksSectionView = LegalLinksSectionView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        headerView.delegate = self
        linksSectionView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(linksSectionView)
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

    // MARK: - Configure

    func configure(content: LegalModels.FetchLegal.ViewModel.Content) {
        linksSectionView.configure(viewModel: content.linksSection)
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

extension LegalContentView: BackNavigationHeaderViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }
}

extension LegalContentView: LegalLinksSectionViewDelegate {
    func didSelectLink(_ action: LegalLinkAction) {
        delegate?.didSelectLink(action)
    }
}
