import UIKit
import Cartography

protocol LanguageContentViewDelegate: AnyObject {
    func didTapBack()
    func didTapCancel()
    func didSelectLanguage(_ language: AppLanguage)
    func didTapSaveChanges()
}

final class LanguageContentView: UIView {

    // MARK: - Properties

    weak var delegate: LanguageContentViewDelegate?

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

    private lazy var headerView = BackNavigationHeaderView(title: Strings.LanguageScene.title)
    private lazy var languageSectionView = LanguageOptionSectionView()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.EditProfileScene.saveChanges, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .accentYellow
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(didTapSaveChanges), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.LanguageScene.cancel, for: .normal)
        button.setTitleColor(.textPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .cardBackground
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()

    private var isSaveEnabled = false

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
        languageSectionView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(languageSectionView)
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

    func configure(content: LanguageModels.FetchLanguage.ViewModel.Content) {
        languageSectionView.configure(viewModel: content.languageSection)
        updateSaveButton(isEnabled: content.isSaveEnabled)
    }

    func setSaving(_ isSaving: Bool) {
        saveButton.isEnabled = !isSaving && isSaveEnabled
        cancelButton.isEnabled = !isSaving
        saveButton.alpha = isSaving ? 0.6 : (isSaveEnabled ? 1 : 0.6)
    }

    // MARK: - Actions

    @objc private func didTapSaveChanges() {
        delegate?.didTapSaveChanges()
    }

    @objc private func didTapCancel() {
        delegate?.didTapCancel()
    }

    // MARK: - Helpers

    private func makeButtonsContainer() -> UIView {
        let stack = UIStackView(arrangedSubviews: [saveButton, cancelButton])
        stack.axis = .vertical
        stack.spacing = 12
        constrainSaveButton()
        constrainCancelButton()
        return stack
    }

    private func constrainSaveButton() {
        constrain(saveButton) { button in
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

    private func updateSaveButton(isEnabled: Bool) {
        isSaveEnabled = isEnabled
        saveButton.isEnabled = isEnabled
        saveButton.alpha = isEnabled ? 1 : 0.6
    }
}

extension LanguageContentView: BackNavigationHeaderViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }
}

extension LanguageContentView: LanguageOptionSectionViewDelegate {
    func didSelectLanguage(_ language: AppLanguage) {
        delegate?.didSelectLanguage(language)
    }
}
