import Foundation

protocol HomeBusinessLogic {
    func fetchContent(request: HomeModels.FetchContent.Request)
    func refresh()
}

final class HomeInteractor {
    private let presenter: HomePresentationLogic
    private let repository: MovieRepositoryProtocol

    init(presenter: HomePresentationLogic, repository: MovieRepositoryProtocol) {
        self.presenter = presenter
        self.repository = repository
    }
}

extension HomeInteractor: HomeBusinessLogic {
    func fetchContent(request: HomeModels.FetchContent.Request) {
        presenter.presentLoading()
        Task { await loadContent() }
    }

    func refresh() {
        Task { await loadContent() }
    }

    private func loadContent() async {
        do {
            async let featured = repository.fetchFeatured()
            async let nowPlaying = repository.fetchNowPlaying()
            async let trending = repository.fetchTrending()
            async let topRated = repository.fetchTopRated()

            let (featuredMovies, nowPlayingMovies, trendingMovies, topRatedMovies) = try await (
                featured, nowPlaying, trending, topRated
            )

            guard let featuredMovie = featuredMovies.first else {
                await MainActor.run { presenter.presentError(NoContentError()) }
                return
            }

            let response = HomeModels.FetchContent.Response(
                featured: featuredMovie,
                nowPlaying: nowPlayingMovies,
                trending: trendingMovies,
                topRated: topRatedMovies
            )
            await MainActor.run { presenter.presentContent(response: response) }
        } catch {
            await MainActor.run { presenter.presentError(error) }
        }
    }
}

private struct NoContentError: Error {}
