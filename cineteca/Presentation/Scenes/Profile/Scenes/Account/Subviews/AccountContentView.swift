import UIKit
import Cartography

protocol AccountContentViewDelegate: AnyObject {
    func didTapBack()
    func didSelectRow(action: AccountModels.RowAction)
}

final class AccountContentView: UIView {

    // MARK: - Properties

    weak var delegate: AccountContentViewDelegate?

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

    private lazy var headerView = BackNavigationHeaderView(title: Strings.AccountScene.title)
    private lazy var profileCardView = AccountProfileCardView()
    private lazy var profileSectionView = AccountSectionView()
    private lazy var securitySectionView = AccountSectionView()
    private lazy var dangerSectionView = AccountSectionView()

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
        profileSectionView.delegate = self
        securitySectionView.delegate = self
        dangerSectionView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(profileCardView)
        contentStack.addArrangedSubview(profileSectionView)
        contentStack.addArrangedSubview(securitySectionView)
        contentStack.addArrangedSubview(dangerSectionView)
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

    func configure(content: AccountModels.FetchAccount.ViewModel.Content) {
        profileCardView.configure(viewModel: content.profileCard)
        profileSectionView.configure(viewModel: content.profileSection)
        securitySectionView.configure(viewModel: content.securitySection)
        dangerSectionView.configure(viewModel: content.dangerSection)
    }

    // MARK: - Helpers

    private func makeSpacer(height: CGFloat) -> UIView {
        let view = UIView()
        constrain(view) { spacer in
            spacer.height == height
        }
        return view
    }
}

extension AccountContentView: BackNavigationHeaderViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }
}

extension AccountContentView: AccountSectionViewDelegate {
    func didSelectRow(action: AccountModels.RowAction) {
        delegate?.didSelectRow(action: action)
    }
}
