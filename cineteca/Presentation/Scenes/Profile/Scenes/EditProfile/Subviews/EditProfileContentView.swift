import UIKit
import Cartography

protocol EditProfileContentViewDelegate: AnyObject {
    func didTapBack()
    func didTapCancel()
    func didTapSave(displayName: String, bio: String)
    func didTapChangePhoto()
}

final class EditProfileContentView: UIView {

    // MARK: - Properties

    weak var delegate: EditProfileContentViewDelegate?

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .appBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    private lazy var headerView = EditProfileHeaderView()
    private lazy var avatarView = EditProfileAvatarView()

    private lazy var usernameField = EditProfileFormFieldView(
        title: Strings.EditProfileScene.Field.username,
        style: .singleLine,
        isEditable: false
    )

    private lazy var displayNameField = EditProfileFormFieldView(
        title: Strings.EditProfileScene.Field.displayName,
        style: .singleLine
    )

    private lazy var bioField = EditProfileFormFieldView(
        title: Strings.EditProfileScene.Field.bio,
        style: .multiline
    )

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.EditProfileScene.saveChanges, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .accentYellow
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.EditProfileScene.cancel, for: .normal)
        button.setTitleColor(.textPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .cardBackground
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()

    private var savedDisplayName = ""
    private var savedBio = ""
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
        avatarView.delegate = self
        displayNameField.onTextChange = { [weak self] in
            self?.evaluateChanges()
        }
        bioField.onTextChange = { [weak self] in
            self?.evaluateChanges()
        }
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(avatarView)
        contentStack.addArrangedSubview(makeFieldsContainer())
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

    func configure(content: EditProfileModels.FetchProfile.ViewModel.Content) {
        savedDisplayName = content.displayName
        savedBio = content.bio
        avatarView.configure(avatarImageName: content.avatarImageName)
        usernameField.configure(text: content.username)
        displayNameField.configure(text: content.displayName)
        bioField.configure(text: content.bio)
        updateSaveButton(isEnabled: false)
    }

    func setSaving(_ isSaving: Bool) {
        saveButton.isEnabled = !isSaving && isSaveEnabled
        cancelButton.isEnabled = !isSaving
        saveButton.alpha = isSaving ? 0.6 : (isSaveEnabled ? 1 : 0.6)
    }

    // MARK: - Actions

    @objc private func didTapSave() {
        endEditing(true)
        delegate?.didTapSave(
            displayName: displayNameField.currentText(),
            bio: bioField.currentText()
        )
    }

    @objc private func didTapCancel() {
        delegate?.didTapCancel()
    }

    // MARK: - Helpers

    private func makeFieldsContainer() -> UIView {
        let stack = UIStackView(arrangedSubviews: [usernameField, displayNameField, bioField])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }

    private func makeButtonsContainer() -> UIView {
        let stack = UIStackView(arrangedSubviews: [saveButton, cancelButton])
        stack.axis = .vertical
        stack.spacing = 12

        constrain(saveButton) { button in
            button.height == 44
        }
        constrain(cancelButton) { button in
            button.height == 44
        }

        return stack
    }

    private func makeSpacer(height: CGFloat) -> UIView {
        let view = UIView()
        constrain(view) { spacer in
            spacer.height == height
        }
        return view
    }

    private func evaluateChanges() {
        let displayName = displayNameField.currentText().trimmingCharacters(in: .whitespacesAndNewlines)
        let bio = bioField.currentText().trimmingCharacters(in: .whitespacesAndNewlines)
        let savedDisplayName = savedDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedBio = savedBio.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasChanges = displayName != savedDisplayName || bio != savedBio
        updateSaveButton(isEnabled: hasChanges)
    }

    private func updateSaveButton(isEnabled: Bool) {
        isSaveEnabled = isEnabled
        saveButton.isEnabled = isEnabled
        saveButton.alpha = isEnabled ? 1 : 0.6
    }
}

// MARK: - EditProfileHeaderViewDelegate

extension EditProfileContentView: EditProfileHeaderViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }
}

// MARK: - EditProfileAvatarViewDelegate

extension EditProfileContentView: EditProfileAvatarViewDelegate {
    func didTapChangePhoto() {
        delegate?.didTapChangePhoto()
    }
}
