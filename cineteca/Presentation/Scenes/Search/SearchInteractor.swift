import Foundation

protocol SearchBusinessLogic {
    func loadContent(request: SearchModels.LoadContent.Request)
    func search(request: SearchModels.Search.Request)
    func updateFilters(request: SearchModels.UpdateFilters.Request)
    func showFilters()
}

final class SearchInteractor {
    private let presenter: SearchPresentationLogic
    private let repository: MovieRepositoryProtocol
    private let genreRepository: GenreRepositoryProtocol

    private var genres: [Genre] = []
    private var filters = SearchFilters()
    private var currentQuery = ""
    private var searchTask: Task<Void, Never>?

    init(
        presenter: SearchPresentationLogic,
        repository: MovieRepositoryProtocol,
        genreRepository: GenreRepositoryProtocol
    ) {
        self.presenter = presenter
        self.repository = repository
        self.genreRepository = genreRepository
    }
}

extension SearchInteractor: SearchBusinessLogic {
    func loadContent(request: SearchModels.LoadContent.Request) {
        presenter.presentLoading(mode: .suggested)
        Task { await loadInitialContent() }
    }

    func search(request: SearchModels.Search.Request) {
        currentQuery = request.query
        searchTask?.cancel()
        searchTask = Task { await performSearch() }
    }

    func updateFilters(request: SearchModels.UpdateFilters.Request) {
        filters = request.filters
        searchTask?.cancel()
        searchTask = Task { await performSearch() }
    }

    func showFilters() {
        presenter.presentFilters(
            response: .init(filters: filters, genres: genres)
        )
    }

    private func loadInitialContent() async {
        do {
            genres = try await genreRepository.genres()
            let suggested = try await repository.fetchTrending(genres: genres)
            await MainActor.run {
                presenter.presentMovies(
                    response: .content(movies: suggested, mode: .suggested)
                )
            }
        } catch {
            await MainActor.run { presenter.presentMovies(response: .error) }
        }
    }

    private func performSearch() async {
        let trimmedQuery = currentQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedQuery.isEmpty, !filters.hasActiveFilters {
            await loadSuggestedContent()
            return
        }

        let loadingMode: SearchModels.DisplayMode = .results
        await MainActor.run { presenter.presentLoading(mode: loadingMode) }

        do {
            let movies: [Movie]
            if filters.hasActiveFilters {
                movies = try await repository.discoverMovies(
                    filters: filters,
                    query: trimmedQuery.isEmpty ? nil : trimmedQuery,
                    genres: genres
                )
            } else {
                movies = try await repository.searchMovies(query: trimmedQuery, genres: genres)
            }

            guard !Task.isCancelled else { return }

            await MainActor.run {
                presenter.presentMovies(
                    response: .content(movies: movies, mode: .results)
                )
            }
        } catch {
            guard !Task.isCancelled else { return }
            await MainActor.run { presenter.presentMovies(response: .error) }
        }
    }

    private func loadSuggestedContent() async {
        let loadingMode: SearchModels.DisplayMode = .suggested
        await MainActor.run { presenter.presentLoading(mode: loadingMode) }

        do {
            let suggested = try await repository.fetchTrending(genres: genres)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                presenter.presentMovies(
                    response: .content(movies: suggested, mode: .suggested)
                )
            }
        } catch {
            guard !Task.isCancelled else { return }
            await MainActor.run { presenter.presentMovies(response: .error) }
        }
    }
}
