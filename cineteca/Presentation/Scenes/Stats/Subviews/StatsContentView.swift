import UIKit
import Cartography

protocol StatsContentViewDelegate: AnyObject {
    func didSelectPeriod(at index: Int)
}

final class StatsContentView: UIView {

    // MARK: - Properties

    weak var delegate: StatsContentViewDelegate?

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
    private lazy var periodFilterView = ChipFilterView()
    private lazy var summaryView = StatCardsView()
    private lazy var genreDistributionView = StatsGenreDistributionView()
    private lazy var topDirectorView = StatsTopPersonView()
    private lazy var topActorView = StatsTopPersonView()
    private lazy var activityView = StatsActivityView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        periodFilterView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(periodFilterView)
        contentStack.addArrangedSubview(summaryView)
        contentStack.setCustomSpacing(0, after: headerView)
        contentStack.setCustomSpacing(12, after: periodFilterView)
        contentStack.addArrangedSubview(genreDistributionView)
        contentStack.addArrangedSubview(topDirectorView)
        contentStack.addArrangedSubview(topActorView)
        contentStack.addArrangedSubview(activityView)
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
            stack.leading == scroll.leading
            stack.trailing == scroll.trailing
            stack.bottom == scroll.bottom
            stack.width == scroll.width
        }
    }

    // MARK: - Configure

    func configure(content: StatsModels.FetchStats.ViewModel.Content) {
        headerView.configure(viewModel: content.header)
        periodFilterView.configure(
            options: content.periodFilter.options,
            selectedIndex: content.periodFilter.selectedIndex
        )
        summaryView.configure(
            viewModel: .init(
                filmsCount: content.summary.filmsCount,
                hoursWatched: content.summary.hoursWatched,
                reviewsCount: content.summary.reviewsCount
            )
        )
        genreDistributionView.configure(viewModel: content.genres)
        topDirectorView.configure(viewModel: content.topDirector)
        topActorView.configure(viewModel: content.topActor)
        activityView.configure(viewModel: content.activity)
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

// MARK: - ChipFilterViewDelegate

extension StatsContentView: ChipFilterViewDelegate {
    func didSelectOption(at index: Int) {
        delegate?.didSelectPeriod(at: index)
    }
}
