import Foundation

protocol HomeBusinessLogic {
    func fetchContent(request: HomeModels.FetchContent.Request)
    func refresh()
    func selectGenre(request: HomeModels.SelectGenre.Request)
}

final class HomeInteractor {
    private let presenter: HomePresentationLogic
    private let repository: MovieRepositoryProtocol
    private let genreRepository: GenreRepositoryProtocol

    private var cachedHomeContent: CachedHomeContent?
    private var genreOptions: [String] = []
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
        guard request.index >= 0, request.index < genreOptions.count else { return }
        selectedGenreIndex = request.index
        guard let cachedHomeContent else { return }
        presentFilteredContent(from: cachedHomeContent)
    }

    private func loadContent() async {
        do {
            async let featured = repository.fetchFeatured()
            async let nowPlaying = repository.fetchNowPlaying()
            async let trending = repository.fetchTrending()
            async let topRated = repository.fetchTopRated()
            async let genreMap = genreRepository.genres()

            let (featuredMovies, nowPlayingMovies, trendingMovies, topRatedMovies, genres) = try await (
                featured, nowPlaying, trending, topRated, genreMap
            )

            guard let featuredMovie = featuredMovies.first else {
                await MainActor.run { presenter.presentError(NoContentError()) }
                return
            }

            genreOptions = buildGenreOptions(from: genres)
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
        let genreName = selectedGenreName
        let response = HomeModels.FetchContent.Response(
            featured: resolveFeatured(from: content, genreName: genreName),
            nowPlaying: filter(content.nowPlaying, by: genreName),
            trending: filter(content.trending, by: genreName),
            topRated: filter(content.topRated, by: genreName),
            genreFilter: GenreFilter(options: genreOptions, selectedIndex: selectedGenreIndex)
        )
        presenter.presentContent(response: response)
    }

    private func buildGenreOptions(from genreMap: [Int: String]) -> [String] {
        let names = genreMap.values.sorted()
        return [Strings.HomeScene.GenreFilter.all] + names
    }

    private var selectedGenreName: String? {
        guard selectedGenreIndex > 0, selectedGenreIndex < genreOptions.count else { return nil }
        return genreOptions[selectedGenreIndex]
    }

    private func filter(_ movies: [Movie], by genreName: String?) -> [Movie] {
        guard let genreName else { return movies }
        return movies.filter { $0.genres.contains(genreName) }
    }

    private func resolveFeatured(from content: CachedHomeContent, genreName: String?) -> Movie {
        guard let genreName else { return content.featured }
        if content.featured.genres.contains(genreName) {
            return content.featured
        }
        return filter(content.nowPlaying, by: genreName).first
            ?? filter(content.trending, by: genreName).first
            ?? filter(content.topRated, by: genreName).first
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
