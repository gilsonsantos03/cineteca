import UIKit
import Cartography

protocol SearchContentViewDelegate: AnyObject {
    func didSelectMovie(at index: Int)
    func didRequestRetry()
}

final class SearchContentView: UIView {

    // MARK: - Properties

    weak var delegate: SearchContentViewDelegate?

    private var movies: [SearchModels.MovieGridViewModel] = []

    private enum GridState {
        case loading
        case content
        case error
    }

    // MARK: - UI Components

    private lazy var sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(SearchMovieGridCell.self, forCellWithReuseIdentifier: SearchMovieGridCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .accentYellow
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var errorStateView = HomeErrorStateView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        errorStateView.delegate = self
        sectionTitleLabel.text = Strings.SearchScene.Section.suggested
        setupSubviews()
        setupConstraints()
        setGridState(.loading)
    }

    private func setupSubviews() {
        addSubview(sectionTitleLabel)
        addSubview(collectionView)
        addSubview(loadingIndicator)
        addSubview(errorStateView)
    }

    private func setupConstraints() {
        constrainSectionTitleLabel()
        constrainCollectionView()
        constrainLoadingIndicator()
        constrainErrorStateView()
    }

    private func constrainSectionTitleLabel() {
        constrain(sectionTitleLabel, self) { label, superview in
            label.top == superview.top + 16
            label.left == superview.left + 20
            label.right == superview.right - 20
        }
    }

    private func constrainCollectionView() {
        constrain(collectionView, sectionTitleLabel, self) { collectionView, title, superview in
            collectionView.top == title.bottom + 16
            collectionView.left == superview.left
            collectionView.right == superview.right
            collectionView.bottom == superview.bottom
        }
    }

    private func constrainLoadingIndicator() {
        constrain(loadingIndicator, collectionView) { indicator, collectionView in
            indicator.centerX == collectionView.centerX
            indicator.centerY == collectionView.centerY
        }
    }

    private func constrainErrorStateView() {
        constrain(errorStateView, collectionView) { errorView, collectionView in
            errorView.edges == collectionView.edges
        }
    }

    // MARK: - Public API

    func showLoading(mode: SearchModels.DisplayMode) {
        updateSectionTitle(for: mode)
        setGridState(.loading)
    }

    func showMovies(movies: [SearchModels.MovieGridViewModel], mode: SearchModels.DisplayMode) {
        self.movies = movies
        updateSectionTitle(for: mode)
        collectionView.reloadData()
        setGridState(.content)
    }

    func showError() {
        setGridState(.error)
    }

    // MARK: - Helpers

    private func updateSectionTitle(for mode: SearchModels.DisplayMode) {
        sectionTitleLabel.text = mode == .suggested
            ? Strings.SearchScene.Section.suggested
            : Strings.SearchScene.Section.results
    }

    private func setGridState(_ state: GridState) {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            collectionView.isHidden = true
            errorStateView.isHidden = true
        case .content:
            loadingIndicator.stopAnimating()
            collectionView.isHidden = false
            errorStateView.isHidden = true
        case .error:
            loadingIndicator.stopAnimating()
            collectionView.isHidden = true
            errorStateView.isHidden = false
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension SearchContentView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchMovieGridCell.reuseId,
            for: indexPath
        ) as! SearchMovieGridCell
        cell.configure(viewModel: movies[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalInset: CGFloat = 20
        let spacing: CGFloat = 12
        let width = (collectionView.bounds.width - horizontalInset * 2 - spacing) / 2
        let posterHeight = width * 1.5
        return CGSize(width: width, height: posterHeight + 54)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 20, bottom: 24, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectMovie(at: indexPath.item)
    }
}

// MARK: - HomeErrorStateViewDelegate

extension SearchContentView: HomeErrorStateViewDelegate {
    func didRequestRetry() {
        delegate?.didRequestRetry()
    }
}
