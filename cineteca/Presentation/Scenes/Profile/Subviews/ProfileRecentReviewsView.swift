import UIKit
import Cartography

final class ProfileRecentReviewsView: UIView {

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.ProfileScene.RecentReviews.title
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.ProfileScene.RecentReviews.seeAll, for: .normal)
        button.setTitleColor(.textSecondary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.isUserInteractionEnabled = false
        return button
    }()

    private lazy var cardsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(seeAllButton)
        addSubview(cardsStack)
    }

    private func setupConstraints() {
        constrainTitleLabel()
        constrainSeeAllButton()
        constrainCardsStack()
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, self) { label, superview in
            label.top == superview.top
            label.left == superview.left + 20
        }
    }

    private func constrainSeeAllButton() {
        constrain(seeAllButton, titleLabel, self) { button, label, superview in
            button.centerY == label.centerY
            button.right == superview.right - 20
        }
    }

    private func constrainCardsStack() {
        constrain(cardsStack, titleLabel, self) { stack, label, superview in
            stack.top == label.bottom + 16
            stack.left == superview.left + 20
            stack.right == superview.right - 20
            stack.bottom == superview.bottom
        }
    }

    // MARK: - Configure

    func configure(viewModel: ProfileModels.RecentReviewsViewModel) {
        cardsStack.arrangedSubviews.forEach {
            cardsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for review in viewModel.reviews {
            let card = ProfileReviewCardView()
            card.configure(viewModel: review)
            cardsStack.addArrangedSubview(card)
        }
    }
}
