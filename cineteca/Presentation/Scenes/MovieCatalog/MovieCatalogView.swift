import UIKit
import Cartography

protocol MovieCatalogViewDelegate: AnyObject {
    func didTapBack()
    func didSelectMovie(id movieId: Int)
    func didRequestRetry()
    func didRequestNextPage()
}

final class MovieCatalogView: UIView {

    // MARK: - Properties

    weak var delegate: MovieCatalogViewDelegate?

    private var movies: [MovieCatalogModels.MovieCardViewModel] = []
    private var allMovies: [MovieCatalogModels.MovieCardViewModel] = []
    private var genreFilterOptions: [String] = []
    private var genreIDs: [Int?] = []
    private var selectedGenreID: Int?

    private enum State {
        case loading
        case content
        case error
    }

    // MARK: - UI Components

    private lazy var headerView = BackNavigationHeaderView(title: title)
    private lazy var genreFilterView = GenreFilterView()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset.bottom = 68
        collectionView.verticalScrollIndicatorInsets.bottom = 68
        collectionView.register(
            MovieCatalogGridCell.self,
            forCellWithReuseIdentifier: MovieCatalogGridCell.reuseId
        )
        collectionView.register(
            MovieCatalogLoadingFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: MovieCatalogLoadingFooterView.reuseId
        )
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

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieCatalogScene.empty
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var errorStateView = ErrorStateView()

    private var hasMorePages = true
    private var isLoadingNextPage = false

    private let title: String

    // MARK: - Initialization

    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        headerView.delegate = self
        genreFilterView.delegate = self
        errorStateView.delegate = self
        setupSubviews()
        setupConstraints()
        setState(.loading)
    }

    private func setupSubviews() {
        addSubview(headerView)
        addSubview(genreFilterView)
        addSubview(collectionView)
        addSubview(loadingIndicator)
        addSubview(emptyStateLabel)
        addSubview(errorStateView)
    }

    private func setupConstraints() {
        constrainHeaderView()
        constrainGenreFilterView()
        constrainCollectionView()
        constrainLoadingIndicator()
        constrainEmptyStateLabel()
        constrainErrorStateView()
    }

    private func constrainHeaderView() {
        constrain(headerView, self) { header, superview in
            header.top == superview.safeAreaLayoutGuide.top + 16
            header.left == superview.left
            header.right == superview.right
        }
    }

    private func constrainCollectionView() {
        constrain(collectionView, genreFilterView, self) {
            collectionView, genreFilter, superview in
            collectionView.top == genreFilter.bottom
            collectionView.left == superview.left
            collectionView.right == superview.right
            collectionView.bottom == superview.bottom
        }
    }

    private func constrainGenreFilterView() {
        constrain(genreFilterView, headerView, self) { genreFilter, header, superview in
            genreFilter.top == header.bottom
            genreFilter.left == superview.left
            genreFilter.right == superview.right
        }
    }

    private func constrainLoadingIndicator() {
        constrain(loadingIndicator, collectionView) { indicator, collectionView in
            indicator.centerX == collectionView.centerX
            indicator.centerY == collectionView.centerY
        }
    }

    private func constrainEmptyStateLabel() {
        constrain(emptyStateLabel, collectionView) { label, collectionView in
            label.centerX == collectionView.centerX
            label.centerY == collectionView.centerY
            label.left == collectionView.left + 24
            label.right == collectionView.right - 24
        }
    }

    private func constrainErrorStateView() {
        constrain(errorStateView, collectionView) { errorView, collectionView in
            errorView.edges == collectionView.edges
        }
    }

    // MARK: - Public API

    func showLoading() {
        isLoadingNextPage = false
        genreFilterView.isHidden = true
        setState(.loading)
    }

    func showContent(content: MovieCatalogModels.FetchContent.ViewModel.Content) {
        allMovies = content.movies
        genreFilterOptions = content.genreFilter.options
        genreIDs = content.genreFilter.genreIDs
        selectedGenreID = genreIDs.first ?? nil
        genreFilterView.configure(
            options: content.genreFilter.options,
            selectedIndex: 0
        )
        hasMorePages = content.hasMorePages
        isLoadingNextPage = false
        applyGenreFilter()
        setState(.content)
    }

    func appendContent(content: MovieCatalogModels.FetchNextPage.ViewModel.Content) {
        allMovies.append(contentsOf: content.movies)
        hasMorePages = content.hasMorePages
        stopLoadingNextPage()
        applyGenreFilter()
    }

    func showLoadingNextPage() {
        isLoadingNextPage = true
        updateVisibleFooter()
    }

    func stopLoadingNextPage() {
        isLoadingNextPage = false
        updateVisibleFooter()
    }

    func showError() {
        isLoadingNextPage = false
        setState(.error)
    }

    // MARK: - Helpers

    private func setState(_ state: State) {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            collectionView.isHidden = true
            emptyStateLabel.isHidden = true
            errorStateView.isHidden = true
        case .content:
            loadingIndicator.stopAnimating()
            collectionView.isHidden = false
            emptyStateLabel.isHidden = !movies.isEmpty
            genreFilterView.isHidden = false
            errorStateView.isHidden = true
        case .error:
            loadingIndicator.stopAnimating()
            collectionView.isHidden = true
            emptyStateLabel.isHidden = true
            genreFilterView.isHidden = true
            errorStateView.isHidden = false
        }
    }

    private func applyGenreFilter() {
        movies = guardSelectedGenre()
        emptyStateLabel.isHidden = !movies.isEmpty
        collectionView.reloadData()
    }

    private func guardSelectedGenre() -> [MovieCatalogModels.MovieCardViewModel] {
        guard let selectedGenreID else { return allMovies }
        return allMovies.filter { $0.genreIDs.contains(selectedGenreID) }
    }

    private func updateVisibleFooter() {
        let footer = collectionView.visibleSupplementaryViews(
            ofKind: UICollectionView.elementKindSectionFooter
        ).first as? MovieCatalogLoadingFooterView
        footer?.setLoading(isLoadingNextPage)
    }

}

// MARK: - BackNavigationHeaderViewDelegate, ErrorStateViewDelegate

extension MovieCatalogView: BackNavigationHeaderViewDelegate, ErrorStateViewDelegate {
    func didTapBack() {
        delegate?.didTapBack()
    }

    func didRequestRetry() {
        delegate?.didRequestRetry()
    }
}

// MARK: - GenreFilterViewDelegate

extension MovieCatalogView: GenreFilterViewDelegate {
    func didSelectGenre(at index: Int) {
        guard genreIDs.indices.contains(index) else { return }
        selectedGenreID = genreIDs[index]
        genreFilterView.configure(
            options: genreFilterOptions,
            selectedIndex: index
        )
        applyGenreFilter()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension MovieCatalogView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movies.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieCatalogGridCell.reuseId,
            for: indexPath
        ) as! MovieCatalogGridCell
        cell.configure(viewModel: movies[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter else {
            return UICollectionReusableView()
        }

        let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: MovieCatalogLoadingFooterView.reuseId,
            for: indexPath
        ) as! MovieCatalogLoadingFooterView
        footer.delegate = self
        footer.setLoading(isLoadingNextPage)
        return footer
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalInset: CGFloat = 20
        let spacing: CGFloat = 12
        let width = (collectionView.bounds.width - horizontalInset * 2 - spacing * 2) / 3
        let posterHeight = width * 1.45
        return CGSize(width: width, height: posterHeight + 42)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 20, bottom: 8, right: 20)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        CGSize(
            width: collectionView.bounds.width,
            height: hasMorePages && !movies.isEmpty ? 72 : 0
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectMovie(id: movies[indexPath.item].id)
    }

}

// MARK: - MovieCatalogLoadingFooterViewDelegate

extension MovieCatalogView: MovieCatalogLoadingFooterViewDelegate {
    func didTapLoadMore() {
        delegate?.didRequestNextPage()
    }
}
