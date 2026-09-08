import UIKit
import Cartography

final class MovieDetailsProvidersView: UIStackView {

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieDetailsScene.Section.whereToWatch
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        axis = .vertical
        spacing = 10
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        scrollView.addSubview(contentStack)
        addArrangedSubview(titleLabel)
        addArrangedSubview(scrollView)
    }

    private func setupConstraints() {
        constrainContentStack()
        constrainScrollView()
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView.contentLayoutGuide, scrollView.frameLayoutGuide) { stack, content, frame in
            stack.top == content.top
            stack.bottom == content.bottom
            stack.left == content.left
            stack.right == content.right
            stack.height == frame.height
        }
    }

    private func constrainScrollView() {
        constrain(scrollView) { scrollView in
            scrollView.height == 70
        }
    }

    // MARK: - Configure

    func configure(_ providers: [MovieDetailsModels.WatchProviderViewModel]) {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        providers.forEach { provider in
            let cardView = MovieDetailsProviderCardView()
            cardView.configure(viewModel: provider)
            contentStack.addArrangedSubview(cardView)
        }
        isHidden = providers.isEmpty
    }
}
