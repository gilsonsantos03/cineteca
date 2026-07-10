import UIKit
import Cartography

final class GenreFilterView: UIView {

    // MARK: - Properties

    private let genres = ["All", "Action", "Drama", "Sci-Fi", "Horror", "Comedy", "Thriller"]
    private var selectedIndex = 0

    // MARK: - UI Components

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(GenreChipCell.self, forCellWithReuseIdentifier: GenreChipCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
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
        addSubview(collectionView)
    }

    private func setupConstraints() {
        constrainCollectionView()
        constrainSelf()
    }

    private func constrainCollectionView() {
        constrain(collectionView, self) { collectionView, superview in
            collectionView.top == superview.top + 20
            collectionView.bottom == superview.bottom - 12
            collectionView.left == superview.left
            collectionView.right == superview.right
            collectionView.height == 40
        }
    }

    private func constrainSelf() {
        constrain(self) { superview in
            superview.height == 72
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension GenreFilterView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        genres.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreChipCell.reuseId, for: indexPath) as! GenreChipCell
        cell.configure(title: genres[indexPath.item], isSelected: indexPath.item == selectedIndex)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
    }
}
