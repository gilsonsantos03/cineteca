import UIKit
import Cartography

protocol MyReviewsContentViewDelegate: AnyObject {
    func didTapBack()
    func didSelectReview(_ review: MyReviewsModels.ReviewCardViewModel)
}

final class MyReviewsContentView: UIView {

    // MARK: - Properties
    
    weak var delegate: MyReviewsContentViewDelegate?

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .appBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    private lazy var headerView = BackNavigationHeaderView(title: Strings.MyReviewsScene.title)

    private lazy var cardsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 14
        return stack
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MyReviewsScene.empty
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .cardBackground
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.heightAnchor.constraint(equalToConstant: 64).isActive = true
        return label
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
        headerView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(cardsStack)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
    }

    private func setupConstraints() {
        constrainScrollView()
        constrainContentStack()
    }

    private func constrainScrollView() {
        constrain(scrollView, self) { scroll, superview in
            scroll.top == superview.safeAreaLayoutGuide.top
            scroll.left == superview.left
            scroll.right == superview.right
            scroll.bottom == superview.bottom
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView) { stack, scroll in
            stack.top == scroll.top + 8
            stack.left == scroll.left + 20
            stack.right == scroll.right - 20
            stack.bottom == scroll.bottom
            stack.width == scroll.width - 40
        }
    }

    func configure(content: MyReviewsModels.FetchReviews.ViewModel.Content) {
        cardsStack.arrangedSubviews.forEach {
            cardsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        guard !content.reviews.isEmpty else {
            cardsStack.addArrangedSubview(emptyStateLabel)
            return
        }

        for review in content.reviews {
            let card = MyReviewCardView()
            card.configure(viewModel: review)
            card.delegate = self
            cardsStack.addArrangedSubview(card)
        }
    }

    private func makeSpacer(height: CGFloat) -> UIView {
        let view = UIView()
        constrain(view) { spacer in
            spacer.height == height
        }
        return view
    }
}

extension MyReviewsContentView: BackNavigationHeaderViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }
}

extension MyReviewsContentView: MyReviewCardViewDelegate {
    func didSelectReview(_ review: MyReviewsModels.ReviewCardViewModel) {
        delegate?.didSelectReview(review)
    }
}
