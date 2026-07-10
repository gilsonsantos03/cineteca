import UIKit
import Cartography

final class MovieCardSkeletonCell: UICollectionViewCell {
    static let reuseId = "MovieCardSkeletonCell"

    // MARK: - UI Components

    private lazy var posterShimmer = ShimmerView(cornerRadius: 10)
    private lazy var titleShimmer = ShimmerView(cornerRadius: 4)
    private lazy var ratingShimmer = ShimmerView(cornerRadius: 4)

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        contentView.addSubview(posterShimmer)
        contentView.addSubview(titleShimmer)
        contentView.addSubview(ratingShimmer)
    }

    private func setupConstraints() {
        constrainPosterShimmer()
        constrainTitleShimmer()
        constrainRatingShimmer()
    }

    private func constrainPosterShimmer() {
        constrain(posterShimmer, contentView) { shimmer, container in
            shimmer.top == container.top
            shimmer.left == container.left
            shimmer.right == container.right
            shimmer.height == 170
        }
    }

    private func constrainTitleShimmer() {
        constrain(titleShimmer, posterShimmer, contentView) { shimmer, poster, container in
            shimmer.top == poster.bottom + 8
            shimmer.left == container.left
            shimmer.right == container.right
            shimmer.height == 12
        }
    }

    private func constrainRatingShimmer() {
        constrain(ratingShimmer, titleShimmer, contentView) { shimmer, title, container in
            shimmer.top == title.bottom + 6
            shimmer.left == container.left
            shimmer.width == 40
            shimmer.height == 12
        }
    }
}
