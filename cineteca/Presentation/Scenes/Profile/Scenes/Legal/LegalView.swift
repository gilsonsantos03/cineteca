import UIKit
import Cartography

protocol LegalViewDelegate: AnyObject {
    func didTapBack()
    func didSelectLink(_ action: LegalLinkAction)
}

final class LegalView: UIView {

    // MARK: - Properties

    weak var delegate: LegalViewDelegate?

    // MARK: - UI Components

    private lazy var contentView = LegalContentView()

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

    func showContent(content: LegalModels.FetchLegal.ViewModel.Content) {
        contentView.configure(content: content)
    }
}

extension LegalView: LegalContentViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }

    func didSelectLink(_ action: LegalLinkAction) {
        delegate?.didSelectLink(action)
    }
}
