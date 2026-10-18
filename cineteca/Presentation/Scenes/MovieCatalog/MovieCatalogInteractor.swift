import Foundation

protocol MovieCatalogBusinessLogic {
    func fetchContent(request: MovieCatalogModels.FetchContent.Request)
    func fetchNextPage(request: MovieCatalogModels.FetchNextPage.Request)
}

final class MovieCatalogInteractor {
    private let presenter: MovieCatalogPresentationLogic
    private let repository: MovieRepositoryProtocol
    private let genreRepository: GenreRepositoryProtocol
    private let category: MovieCollectionCategory
    private var currentPage = 0
    private var hasMorePages = true
    private var isLoading = false
    private var loadedMovieIDs = Set<Int>()

    init(
        presenter: MovieCatalogPresentationLogic,
        repository: MovieRepositoryProtocol,
        genreRepository: GenreRepositoryProtocol,
        category: MovieCollectionCategory
    ) {
        self.presenter = presenter
        self.repository = repository
        self.genreRepository = genreRepository
        self.category = category
    }
}

extension MovieCatalogInteractor: MovieCatalogBusinessLogic {
    func fetchContent(request: MovieCatalogModels.FetchContent.Request) {
        guard !isLoading else { return }
        currentPage = 0
        hasMorePages = true
        loadedMovieIDs.removeAll()
        isLoading = true
        presenter.presentLoading()
        Task { await loadInitialContent() }
    }

    func fetchNextPage(request: MovieCatalogModels.FetchNextPage.Request) {
        guard !isLoading, hasMorePages else { return }
        isLoading = true
        presenter.presentLoadingNextPage()
        let nextPage = currentPage + 1
        Task { await loadNextPage(nextPage) }
    }

    private func loadInitialContent() async {
        do {
            let genres = try await genreRepository.genres()
            let page = try await repository.fetchMovieCollection(
                category: category,
                page: 1,
                genres: genres
            )

            await MainActor.run {
                let uniquePage = self.pageRemovingDuplicates(from: page)
                self.currentPage = uniquePage.page
                self.hasMorePages = uniquePage.hasMorePages
                self.isLoading = false
                presenter.presentFetchContent(
                    response: .content(page: uniquePage, genres: genres)
                )
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                presenter.presentFetchContent(response: .error)
            }
        }
    }

    private func loadNextPage(_ page: Int) async {
        do {
            let genres = try await genreRepository.genres()
            let moviePage = try await repository.fetchMovieCollection(
                category: category,
                page: page,
                genres: genres
            )

            await MainActor.run {
                let uniquePage = self.pageRemovingDuplicates(from: moviePage)
                self.currentPage = uniquePage.page
                self.hasMorePages = uniquePage.hasMorePages
                self.isLoading = false
                presenter.presentFetchNextPage(response: .content(uniquePage))
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                presenter.presentFetchNextPage(response: .error)
            }
        }
    }

    private func pageRemovingDuplicates(from page: MovieCollectionPage) -> MovieCollectionPage {
        let uniqueMovies = page.movies.filter { loadedMovieIDs.insert($0.id).inserted }
        return MovieCollectionPage(
            movies: uniqueMovies,
            page: page.page,
            totalPages: page.totalPages
        )
    }
}
