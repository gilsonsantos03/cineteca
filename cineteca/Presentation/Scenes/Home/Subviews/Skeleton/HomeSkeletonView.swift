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

    private lazy var featuredContainer = UIView()
    private lazy var featuredBackdropShimmer = ShimmerView(cornerRadius: 0)
    private lazy var featuredMetaShimmer = ShimmerView(cornerRadius: 4)
    private lazy var featuredTitleShimmer = ShimmerView(cornerRadius: 6)
    private lazy var featuredButtonShimmer = ShimmerView(cornerRadius: 22)

    private lazy var nowPlayingSkeleton = MovieSectionSkeletonView()
    private lazy var trendingSkeleton = MovieSectionSkeletonView()
    private lazy var topRatedSkeleton = MovieSectionSkeletonView()

    private lazy var weeklyDigestContainer = UIView()
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

        featuredContainer.addSubview(featuredBackdropShimmer)
        featuredContainer.addSubview(featuredMetaShimmer)
        featuredContainer.addSubview(featuredTitleShimmer)
        featuredContainer.addSubview(featuredButtonShimmer)

        weeklyDigestContainer.addSubview(weeklyDigestShimmer)

        contentStack.addArrangedSubview(featuredContainer)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
        contentStack.addArrangedSubview(nowPlayingSkeleton)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
        contentStack.addArrangedSubview(trendingSkeleton)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
        contentStack.addArrangedSubview(topRatedSkeleton)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
        contentStack.addArrangedSubview(weeklyDigestContainer)
        contentStack.addArrangedSubview(makeSpacer(height: 32))
    }

    private func setupConstraints() {
        constrainScrollView()
        constrainContentStack()
        constrainFeaturedBackdropShimmer()
        constrainFeaturedButtonShimmer()
        constrainFeaturedTitleShimmer()
        constrainFeaturedMetaShimmer()
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
        constrain(featuredBackdropShimmer, featuredContainer) { shimmer, container in
            shimmer.top == container.top
            shimmer.left == container.left
            shimmer.right == container.right
            shimmer.height == 420
            shimmer.bottom == container.bottom
        }
    }

    private func constrainFeaturedButtonShimmer() {
        constrain(featuredButtonShimmer, featuredBackdropShimmer, featuredContainer) { shimmer, backdrop, container in
            shimmer.left == container.left + 20
            shimmer.right == container.right - 20
            shimmer.bottom == backdrop.bottom - 20
            shimmer.height == 44
        }
    }

    private func constrainFeaturedTitleShimmer() {
        constrain(featuredTitleShimmer, featuredButtonShimmer, featuredContainer) { shimmer, button, container in
            shimmer.left == container.left + 20
            shimmer.right == container.right - 80
            shimmer.bottom == button.top - 24
            shimmer.height == 28
        }
    }

    private func constrainFeaturedMetaShimmer() {
        constrain(featuredMetaShimmer, featuredTitleShimmer, featuredContainer) { shimmer, title, container in
            shimmer.left == container.left + 20
            shimmer.width == 160
            shimmer.bottom == title.top - 8
            shimmer.height == 14
        }
    }

    private func constrainWeeklyDigestShimmer() {
        constrain(weeklyDigestShimmer, weeklyDigestContainer) { shimmer, container in
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
