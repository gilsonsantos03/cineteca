import UIKit
import Cartography

protocol MyReviewsViewDelegate: AnyObject {
    func didTapBack()
    func didSelectReview(_ review: MyReviewsModels.ReviewCardViewModel)
}

final class MyReviewsView: UIView {
    weak var delegate: MyReviewsViewDelegate?

    private lazy var contentView = MyReviewsContentView()
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .accentYellow
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

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
        constrainContentView()
        constrainLoadingIndicator()
    }

    private func constrainContentView() {
        constrain(contentView, self) { view, superview in
            view.edges == superview.edges
        }
    }

    private func constrainLoadingIndicator() {
        constrain(loadingIndicator, self) { indicator, superview in
            indicator.centerX == superview.centerX
            indicator.centerY == superview.centerY
        }
    }

    func showLoading() {
        contentView.isHidden = true
        loadingIndicator.startAnimating()
    }

    func showContent(content: MyReviewsModels.FetchReviews.ViewModel.Content) {
        loadingIndicator.stopAnimating()
        contentView.configure(content: content)
        contentView.isHidden = false
    }

    func showError() {
        loadingIndicator.stopAnimating()
        contentView.isHidden = true
    }
}

extension MyReviewsView: MyReviewsContentViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }

    func didSelectReview(_ review: MyReviewsModels.ReviewCardViewModel) {
        delegate?.didSelectReview(review)
    }
}
