import UIKit
import Cartography

final class MovieSectionView: UIView {

    // MARK: - Properties

    private let sectionTitle: String
    private var movies: [MovieCardViewModel] = []

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = sectionTitle
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        return label
    }()

    private lazy var seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See all", for: .normal)
        button.setTitleColor(.textSecondary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.itemSize = CGSize(width: 140, height: 210)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.register(MovieCardCell.self, forCellWithReuseIdentifier: MovieCardCell.reuseId)
        collectionView.dataSource = self
        return collectionView
    }()

    // MARK: - Initialization

    init(title: String) {
        self.sectionTitle = title
        super.init(frame: .zero)
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
        addSubview(titleLabel)
        addSubview(seeAllButton)
        addSubview(collectionView)
    }

    private func setupConstraints() {
        constrainTitleLabel()
        constrainSeeAllButton()
        constrainCollectionView()
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, self) { label, superview in
            label.top == superview.top + 4
            label.left == superview.left + 20
        }
    }

    private func constrainSeeAllButton() {
        constrain(seeAllButton, titleLabel, self) { button, label, superview in
            button.centerY == label.centerY
            button.right == superview.right - 20
        }
    }

    private func constrainCollectionView() {
        constrain(collectionView, titleLabel, self) { collectionView, label, superview in
            collectionView.top == label.bottom + 12
            collectionView.left == superview.left
            collectionView.right == superview.right
            collectionView.height == 210
            collectionView.bottom == superview.bottom
        }
    }

    // MARK: - Configure

    func configure(movies: [MovieCardViewModel]) {
        self.movies = movies
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension MovieSectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCardCell.reuseId, for: indexPath) as! MovieCardCell
        cell.configure(viewModel: movies[indexPath.item])
        return cell
    }
}
