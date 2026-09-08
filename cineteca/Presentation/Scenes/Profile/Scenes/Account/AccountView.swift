import UIKit
import Cartography

protocol AccountViewDelegate: AnyObject {
    func didTapBack()
    func didSelectRow(action: AccountRowAction)
}

final class AccountView: UIView {

    // MARK: - Properties

    weak var delegate: AccountViewDelegate?

    // MARK: - UI Components

    private lazy var contentView = AccountContentView()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .accentYellow
        indicator.hidesWhenStopped = true
        return indicator
    }()

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
        addSubview(loadingIndicator)
    }

    private func setupConstraints() {
        constrain(contentView, self) { view, superview in
            view.edges == superview.edges
        }
        constrain(loadingIndicator, self) { indicator, superview in
            indicator.centerX == superview.centerX
            indicator.centerY == superview.centerY
        }
    }

    // MARK: - Public API

    func showLoading() {
        contentView.isHidden = true
        loadingIndicator.startAnimating()
    }

    func showContent(content: AccountModels.FetchAccount.ViewModel.Content) {
        loadingIndicator.stopAnimating()
        contentView.configure(content: content)
        contentView.isHidden = false
    }

    func showError() {
        loadingIndicator.stopAnimating()
        contentView.isHidden = true
    }
}

extension AccountView: AccountContentViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }

    func didSelectRow(action: AccountRowAction) {
        delegate?.didSelectRow(action: action)
    }
}
