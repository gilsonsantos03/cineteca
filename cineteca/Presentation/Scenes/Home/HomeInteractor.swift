import Foundation

protocol HomeBusinessLogic {
    func fetchContent(request: HomeModels.FetchContent.Request)
    func refresh()
    func selectGenre(request: HomeModels.SelectGenre.Request)
    func watchTrailer(request: HomeModels.WatchTrailer.Request)
}

final class HomeInteractor {
    private let presenter: HomePresentationLogic
    private let repository: MovieRepositoryProtocol
    private let genreRepository: GenreRepositoryProtocol

    private var cachedHomeContent: CachedHomeContent?
    private var sortedGenres: [Genre] = []
    private var selectedGenreIndex = 0

    init(
        presenter: HomePresentationLogic,
        repository: MovieRepositoryProtocol,
        genreRepository: GenreRepositoryProtocol
    ) {
        self.presenter = presenter
        self.repository = repository
        self.genreRepository = genreRepository
    }
}

extension HomeInteractor: HomeBusinessLogic {
    func fetchContent(request: HomeModels.FetchContent.Request) {
        presenter.presentLoading()
        Task { await loadContent() }
    }

    func refresh() {
        Task {
            await genreRepository.invalidateCache()
            await loadContent()
        }
    }

    func selectGenre(request: HomeModels.SelectGenre.Request) {
        guard request.index != selectedGenreIndex else { return }
        guard request.index >= 0, request.index <= sortedGenres.count else { return }
        selectedGenreIndex = request.index
        guard let cachedHomeContent else { return }
        presentFilteredContent(from: cachedHomeContent)
    }

    func watchTrailer(request: HomeModels.WatchTrailer.Request) {
        Task {
            let response: HomeModels.WatchTrailer.Response
            do {
                if let youtubeKey = try await repository.fetchTrailerKey(for: request.movieId) {
                    response = .success(youtubeKey: youtubeKey)
                } else {
                    response = .unavailable
                }
            } catch {
                response = .unavailable
            }
            await MainActor.run { presenter.presentWatchTrailer(response: response) }
        }
    }

    private func loadContent() async {
        do {
            let genres = try await genreRepository.genres()

            async let featured = repository.fetchFeatured(genres: genres)
            async let nowPlaying = repository.fetchNowPlaying(genres: genres)
            async let trending = repository.fetchTrending(genres: genres)
            async let topRated = repository.fetchTopRated(genres: genres)

            let (featuredMovies, nowPlayingMovies, trendingMovies, topRatedMovies) = try await (
                featured, nowPlaying, trending, topRated
            )

            guard let featuredMovie = featuredMovies.first else {
                await MainActor.run { presenter.presentError(NoContentError()) }
                return
            }

            sortedGenres = genres.sorted { $0.name < $1.name }
            let content = CachedHomeContent(
                featured: featuredMovie,
                nowPlaying: nowPlayingMovies,
                trending: trendingMovies,
                topRated: topRatedMovies
            )
            cachedHomeContent = content
            await MainActor.run { presentFilteredContent(from: content) }
        } catch {
            await MainActor.run { presenter.presentError(error) }
        }
    }

    private func presentFilteredContent(from content: CachedHomeContent) {
        let selectedGenre = selectedGenre
        let response = HomeModels.FetchContent.Response(
            featured: resolveFeatured(from: content, genre: selectedGenre),
            nowPlaying: filter(content.nowPlaying, by: selectedGenre),
            trending: filter(content.trending, by: selectedGenre),
            topRated: filter(content.topRated, by: selectedGenre),
            genreFilter: GenreFilter(genres: sortedGenres, selectedIndex: selectedGenreIndex)
        )
        presenter.presentContent(response: response)
    }

    private var selectedGenre: Genre? {
        guard selectedGenreIndex > 0, selectedGenreIndex <= sortedGenres.count else { return nil }
        return sortedGenres[selectedGenreIndex - 1]
    }

    private func filter(_ movies: [Movie], by genre: Genre?) -> [Movie] {
        guard let genre else { return movies }
        return movies.filter { movie in
            movie.genres.contains { $0.id == genre.id }
        }
    }

    private func resolveFeatured(from content: CachedHomeContent, genre: Genre?) -> Movie {
        guard let genre else { return content.featured }
        if content.featured.genres.contains(where: { $0.id == genre.id }) {
            return content.featured
        }
        return filter(content.nowPlaying, by: genre).first
            ?? filter(content.trending, by: genre).first
            ?? filter(content.topRated, by: genre).first
            ?? content.featured
    }
}

private struct CachedHomeContent {
    let featured: Movie
    let nowPlaying: [Movie]
    let trending: [Movie]
    let topRated: [Movie]
}

private struct NoContentError: Error {}
