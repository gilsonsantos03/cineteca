import UIKit
import Cartography

protocol AppearanceViewDelegate: AnyObject {
    func didTapBack()
    func didTapCancel()
    func didSelectTheme(_ theme: AppTheme)
    func didTapApplyChanges()
}

final class AppearanceView: UIView {

    // MARK: - Properties

    weak var delegate: AppearanceViewDelegate?

    // MARK: - UI Components

    private lazy var contentView = AppearanceContentView()

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

    func showContent(content: AppearanceModels.FetchAppearance.ViewModel.Content) {
        contentView.configure(content: content)
    }

    func setApplying(_ isApplying: Bool) {
        contentView.setApplying(isApplying)
    }
}

extension AppearanceView: AppearanceContentViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }

    func didTapCancel() {
        delegate?.didTapCancel()
    }

    func didSelectTheme(_ theme: AppTheme) {
        delegate?.didSelectTheme(theme)
    }

    func didTapApplyChanges() {
        delegate?.didTapApplyChanges()
    }
}
