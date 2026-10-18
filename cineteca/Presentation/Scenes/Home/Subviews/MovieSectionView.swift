import UIKit
import Cartography

protocol MovieSectionViewDelegate: AnyObject {
    func didSelectMovie(id movieId: Int)
    func didTapSeeAll(category: MovieCollectionCategory, title: String)
}

final class MovieSectionView: UIView {

    // MARK: - Properties

    weak var delegate: MovieSectionViewDelegate?
    private let sectionTitle: String
    private let category: MovieCollectionCategory
    private var movies: [HomeModels.MovieCardViewModel] = []
    private let populatedSectionHeight: CGFloat = 210
    private let emptySectionHeight: CGFloat = 120

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = sectionTitle
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.HomeScene.Section.seeAll, for: .normal)
        button.setTitleColor(.textSecondary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.addTarget(self, action: #selector(didTapSeeAll), for: .touchUpInside)
        return button
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.HomeScene.Section.empty
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var collectionHeightConstraint = collectionView.heightAnchor.constraint(
        equalToConstant: populatedSectionHeight
    )

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
        collectionView.delegate = self
        return collectionView
    }()

    // MARK: - Initialization

    init(title: String, category: MovieCollectionCategory) {
        self.sectionTitle = title
        self.category = category
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
        addSubview(emptyStateLabel)
        emptyStateLabel.isHidden = true
    }

    private func setupConstraints() {
        constrainTitleLabel()
        constrainSeeAllButton()
        constrainCollectionView()
        constrainEmptyStateLabel()
        collectionHeightConstraint.isActive = true
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
            collectionView.bottom == superview.bottom
        }
    }

    private func constrainEmptyStateLabel() {
        constrain(emptyStateLabel, collectionView, self) { label, collectionView, superview in
            label.centerY == collectionView.centerY
            label.left == superview.left + 20
            label.right == superview.right - 20
        }
    }

    // MARK: - Configure

    func configure(movies: [HomeModels.MovieCardViewModel]) {
        self.movies = movies
        let isEmpty = movies.isEmpty
        collectionHeightConstraint.constant = isEmpty ? emptySectionHeight : populatedSectionHeight
        collectionView.isHidden = isEmpty
        emptyStateLabel.isHidden = !isEmpty
        collectionView.reloadData()
    }

    // MARK: - Actions

    @objc private func didTapSeeAll() {
        delegate?.didTapSeeAll(category: category, title: sectionTitle)
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

// MARK: - UICollectionViewDelegate

extension MovieSectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectMovie(id: movies[indexPath.item].id)
    }
}
