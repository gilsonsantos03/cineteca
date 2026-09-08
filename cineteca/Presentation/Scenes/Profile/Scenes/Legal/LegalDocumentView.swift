import UIKit
import Cartography

protocol LegalDocumentViewDelegate: AnyObject {
    func didTapBack()
}

final class LegalDocumentView: UIView {

    // MARK: - Properties

    weak var delegate: LegalDocumentViewDelegate?

    // MARK: - UI Components

    private let contentView: LegalDocumentContentView

    // MARK: - Initialization

    init(content: LegalDocumentContent) {
        self.contentView = LegalDocumentContentView(content: content)
        super.init(frame: .zero)
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
}

extension LegalDocumentView: LegalDocumentContentViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }
}
