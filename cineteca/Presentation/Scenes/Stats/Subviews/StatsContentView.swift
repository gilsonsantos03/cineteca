import UIKit
import Cartography

final class StatsContentView: UIView {

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .appBackground
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    private lazy var headerView = StatsHeaderView()
    private lazy var summaryView = ProfileStatsView()
    private lazy var genreDistributionView = StatsGenreDistributionView()
    private lazy var topDirectorView = StatsTopPersonView()
    private lazy var topActorView = StatsTopPersonView()
    private lazy var monthlyActivityView = StatsMonthlyActivityView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(summaryView)
        contentStack.addArrangedSubview(genreDistributionView)
        contentStack.addArrangedSubview(topDirectorView)
        contentStack.addArrangedSubview(topActorView)
        contentStack.addArrangedSubview(monthlyActivityView)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
    }

    private func setupConstraints() {
        constrainScrollView()
        constrainContentStack()
    }

    private func constrainScrollView() {
        constrain(scrollView, self) { scroll, superview in
            scroll.edges == superview.edges
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView) { stack, scroll in
            stack.top == scroll.top + 16
            stack.left == scroll.left
            stack.right == scroll.right
            stack.bottom == scroll.bottom
            stack.width == scroll.width
        }
    }

    // MARK: - Configure

    func configure(content: StatsModels.FetchStats.ViewModel.Content) {
        headerView.configure(viewModel: content.header)
        summaryView.configure(viewModel: content.summary)
        genreDistributionView.configure(viewModel: content.genres)
        topDirectorView.configure(viewModel: content.topDirector)
        topActorView.configure(viewModel: content.topActor)
        monthlyActivityView.configure(viewModel: content.monthlyActivity)
    }

    // MARK: - Helpers

    private func makeSpacer(height: CGFloat) -> UIView {
        let view = UIView()
        constrain(view) { spacer in
            spacer.height == height
        }
        return view
    }
}
