import UIKit
import Cartography

protocol LanguageViewDelegate: AnyObject {
    func didTapBack()
    func didTapCancel()
    func didSelectLanguage(_ language: AppLanguage)
    func didTapSaveChanges()
}

final class LanguageView: UIView {

    // MARK: - Properties

    weak var delegate: LanguageViewDelegate?

    // MARK: - UI Components

    private lazy var contentView = LanguageContentView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        contentView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(contentView)
    }

    private func setupConstraints() {
        constrainContentView()
    }

    private func constrainContentView() {
        constrain(contentView, self) { view, superview in
            view.edges == superview.edges
        }
    }

    // MARK: - Public API

    func showContent(content: LanguageModels.FetchLanguage.ViewModel.Content) {
        contentView.configure(content: content)
    }

    func setSaving(_ isSaving: Bool) {
        contentView.setSaving(isSaving)
    }
}

extension LanguageView: LanguageContentViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }

    func didTapCancel() {
        delegate?.didTapCancel()
    }

    func didSelectLanguage(_ language: AppLanguage) {
        delegate?.didSelectLanguage(language)
    }

    func didTapSaveChanges() {
        delegate?.didTapSaveChanges()
    }
}
