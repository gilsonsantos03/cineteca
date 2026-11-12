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
    private var initialContentTask: Task<Void, Never>?
    private var contentGeneration = 0
    private var isInitialContentLoading = false
    private var genresTask: Task<[Genre], Error>?
    private var genresTaskID: UUID?

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
        contentGeneration += 1
        let generation = contentGeneration
        isInitialContentLoading = true
        initialContentTask?.cancel()
        initialContentTask = Task { await loadInitialContent(generation: generation) }
    }

    func search(request: SearchModels.Search.Request) {
        currentQuery = request.query
        startSearch()
    }

    func updateFilters(request: SearchModels.UpdateFilters.Request) {
        filters = request.filters
        startSearch()
    }

    private func startSearch() {
        contentGeneration += 1
        isInitialContentLoading = false
        initialContentTask?.cancel()
        searchTask?.cancel()
        searchTask = Task { await performSearch() }
    }

    func showFilters() {
        presenter.presentFilters(
            response: .init(filters: filters, genres: genres)
        )
    }

    private func loadGenres() async throws -> [Genre] {
        if let genresTask {
            return try await genresTask.value
        }
        let taskID = UUID()
        let task = Task { try await genreRepository.genres() }
        genresTaskID = taskID
        genresTask = task
        do {
            let loaded = try await task.value
            if genresTaskID == taskID {
                genresTask = nil
                genresTaskID = nil
            }
            genres = loaded
            return loaded
        } catch {
            if genresTaskID == taskID {
                genresTask = nil
                genresTaskID = nil
            }
            throw error
        }
    }

    private func loadInitialContent(generation: Int) async {
        do {
            let loaded = try await loadGenres()
            guard !Task.isCancelled, generation == contentGeneration else { return }
            let suggested = try await repository.fetchTrending(genres: loaded)
            guard !Task.isCancelled, generation == contentGeneration else { return }
            isInitialContentLoading = false
            await MainActor.run {
                presenter.presentMovies(
                    response: .content(movies: suggested, mode: .suggested)
                )
            }
        } catch {
            guard !Task.isCancelled, generation == contentGeneration else { return }
            isInitialContentLoading = false
            await MainActor.run { presenter.presentMovies(response: .error) }
        }
    }

    private func performSearch() async {
        if isInitialContentLoading {
            initialContentTask?.cancel()
            isInitialContentLoading = false
        }
        let trimmedQuery = currentQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedQuery.isEmpty, !filters.hasActiveFilters {
            await loadSuggestedContent()
            return
        }

        let loadingMode: SearchModels.DisplayMode = .results
        await MainActor.run { presenter.presentLoading(mode: loadingMode) }

        do {
            let loadedGenres = try await loadGenres()
            guard !Task.isCancelled else { return }
            let movies: [Movie]
            if filters.hasActiveFilters {
                movies = try await repository.discoverMovies(
                    filters: filters,
                    query: trimmedQuery.isEmpty ? nil : trimmedQuery,
                    genres: loadedGenres
                )
            } else {
                movies = try await repository.searchMovies(query: trimmedQuery, genres: loadedGenres)
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
            let loadedGenres = try await loadGenres()
            guard !Task.isCancelled else { return }
            let suggested = try await repository.fetchTrending(genres: loadedGenres)
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
