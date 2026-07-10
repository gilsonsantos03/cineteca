import UIKit
import Cartography

final class MovieSectionSkeletonView: UIView {

    // MARK: - Properties

    private static let skeletonCardCount = 3

    // MARK: - UI Components

    private lazy var titleShimmer = ShimmerView(cornerRadius: 4)

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.itemSize = CGSize(width: 140, height: 210)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(MovieCardSkeletonCell.self, forCellWithReuseIdentifier: MovieCardSkeletonCell.reuseId)
        collectionView.dataSource = self
        return collectionView
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
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(titleShimmer)
        addSubview(collectionView)
    }

    private func setupConstraints() {
        constrainTitleShimmer()
        constrainCollectionView()
    }

    private func constrainTitleShimmer() {
        constrain(titleShimmer, self) { shimmer, superview in
            shimmer.top == superview.top + 4
            shimmer.left == superview.left + 20
            shimmer.width == 140
            shimmer.height == 16
        }
    }

    private func constrainCollectionView() {
        constrain(collectionView, titleShimmer, self) { collectionView, shimmer, superview in
            collectionView.top == shimmer.bottom + 12
            collectionView.left == superview.left
            collectionView.right == superview.right
            collectionView.height == 210
            collectionView.bottom == superview.bottom
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MovieSectionSkeletonView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Self.skeletonCardCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: MovieCardSkeletonCell.reuseId, for: indexPath)
    }
}
