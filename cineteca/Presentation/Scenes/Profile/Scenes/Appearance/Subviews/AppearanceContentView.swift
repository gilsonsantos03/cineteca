import UIKit
import Cartography

protocol AppearanceContentViewDelegate: AnyObject {
    func didTapBack()
    func didTapCancel()
    func didSelectTheme(_ theme: AppTheme)
    func didTapApplyChanges()
}

final class AppearanceContentView: UIView {

    // MARK: - Properties

    weak var delegate: AppearanceContentViewDelegate?

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

    private lazy var headerView = BackNavigationHeaderView(title: Strings.AppearanceScene.title)
    private lazy var themeSectionView = AppearanceThemeSectionView()

    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.EditProfileScene.saveChanges, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .accentYellow
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(didTapApplyChanges), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.AppearanceScene.cancel, for: .normal)
        button.setTitleColor(.textPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .cardBackground
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()

    private var isApplyEnabled = false

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
        themeSectionView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(themeSectionView)
        contentStack.addArrangedSubview(makeButtonsContainer())
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

    func configure(content: AppearanceModels.FetchAppearance.ViewModel.Content) {
        themeSectionView.configure(viewModel: content.themeSection)
        updateApplyButton(isEnabled: content.isApplyEnabled)
    }

    func setApplying(_ isApplying: Bool) {
        applyButton.isEnabled = !isApplying && isApplyEnabled
        cancelButton.isEnabled = !isApplying
        applyButton.alpha = isApplying ? 0.6 : (isApplyEnabled ? 1 : 0.6)
    }

    // MARK: - Actions

    @objc private func didTapApplyChanges() {
        delegate?.didTapApplyChanges()
    }

    @objc private func didTapCancel() {
        delegate?.didTapCancel()
    }

    // MARK: - Helpers

    private func makeButtonsContainer() -> UIView {
        let stack = UIStackView(arrangedSubviews: [applyButton, cancelButton])
        stack.axis = .vertical
        stack.spacing = 12
        constrainApplyButton()
        constrainCancelButton()
        return stack
    }

    private func constrainApplyButton() {
        constrain(applyButton) { button in
            button.height == 44
        }
    }

    private func constrainCancelButton() {
        constrain(cancelButton) { button in
            button.height == 44
        }
    }

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

    private func updateApplyButton(isEnabled: Bool) {
        isApplyEnabled = isEnabled
        applyButton.isEnabled = isEnabled
        applyButton.alpha = isEnabled ? 1 : 0.6
    }
}

extension AppearanceContentView: BackNavigationHeaderViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }
}

extension AppearanceContentView: AppearanceThemeSectionViewDelegate {
    func didSelectTheme(_ theme: AppTheme) {
        delegate?.didSelectTheme(theme)
    }
}
