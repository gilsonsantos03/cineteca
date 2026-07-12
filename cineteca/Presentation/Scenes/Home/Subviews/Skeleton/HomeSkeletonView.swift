import UIKit
import Cartography

final class HomeSkeletonView: UIView {

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .appBackground
        scrollView.isScrollEnabled = false
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private lazy var featuredContainerView = UIView()
    private lazy var featuredBackdropShimmer = ShimmerView(cornerRadius: 0)
    private lazy var featuredRatingYearShimmer = ShimmerView(cornerRadius: 4)
    private lazy var featuredTitleShimmer = ShimmerView(cornerRadius: 6)
    private lazy var featuredButtonShimmer = ShimmerView(cornerRadius: 22)

    private lazy var nowPlayingSectionSkeletonView = MovieSectionSkeletonView()
    private lazy var trendingSectionSkeletonView = MovieSectionSkeletonView()
    private lazy var topRatedSectionSkeletonView = MovieSectionSkeletonView()

    private lazy var weeklyDigestContainerView = UIView()
    private lazy var weeklyDigestShimmer = ShimmerView(cornerRadius: 14)

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

        featuredContainerView.addSubview(featuredBackdropShimmer)
        featuredContainerView.addSubview(featuredRatingYearShimmer)
        featuredContainerView.addSubview(featuredTitleShimmer)
        featuredContainerView.addSubview(featuredButtonShimmer)

        weeklyDigestContainerView.addSubview(weeklyDigestShimmer)

        contentStack.addArrangedSubview(featuredContainerView)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
        contentStack.addArrangedSubview(nowPlayingSectionSkeletonView)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
        contentStack.addArrangedSubview(trendingSectionSkeletonView)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
        contentStack.addArrangedSubview(topRatedSectionSkeletonView)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
        contentStack.addArrangedSubview(weeklyDigestContainerView)
        contentStack.addArrangedSubview(makeSpacer(height: 32))
    }

    private func setupConstraints() {
        constrainScrollView()
        constrainContentStack()
        constrainFeaturedBackdropShimmer()
        constrainFeaturedButtonShimmer()
        constrainFeaturedTitleShimmer()
        constrainFeaturedRatingYearShimmer()
        constrainWeeklyDigestShimmer()
    }

    private func constrainScrollView() {
        constrain(scrollView, self) { scrollView, superview in
            scrollView.edges == superview.edges
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView) { stack, scrollView in
            stack.top == scrollView.top
            stack.left == scrollView.left
            stack.right == scrollView.right
            stack.bottom == scrollView.bottom
            stack.width == scrollView.width
        }
    }

    private func constrainFeaturedBackdropShimmer() {
        constrain(featuredBackdropShimmer, featuredContainerView) { shimmer, container in
            shimmer.top == container.top
            shimmer.left == container.left
            shimmer.right == container.right
            shimmer.height == 420
            shimmer.bottom == container.bottom
        }
    }

    private func constrainFeaturedButtonShimmer() {
        constrain(featuredButtonShimmer, featuredBackdropShimmer, featuredContainerView) { shimmer, backdrop, container in
            shimmer.left == container.left + 20
            shimmer.right == container.right - 20
            shimmer.bottom == backdrop.bottom - 20
            shimmer.height == 44
        }
    }

    private func constrainFeaturedTitleShimmer() {
        constrain(featuredTitleShimmer, featuredButtonShimmer, featuredContainerView) { shimmer, button, container in
            shimmer.left == container.left + 20
            shimmer.right == container.right - 80
            shimmer.bottom == button.top - 24
            shimmer.height == 28
        }
    }

    private func constrainFeaturedRatingYearShimmer() {
        constrain(featuredRatingYearShimmer, featuredTitleShimmer, featuredContainerView) { shimmer, title, container in
            shimmer.left == container.left + 20
            shimmer.width == 160
            shimmer.bottom == title.top - 8
            shimmer.height == 14
        }
    }

    private func constrainWeeklyDigestShimmer() {
        constrain(weeklyDigestShimmer, weeklyDigestContainerView) { shimmer, container in
            shimmer.top == container.top
            shimmer.bottom == container.bottom
            shimmer.left == container.left + 20
            shimmer.right == container.right - 20
            shimmer.height == 72
        }
    }

    // MARK: - Helpers

    private func makeSpacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        constrain(spacer) { $0.height == height }
        return spacer
    }
}
