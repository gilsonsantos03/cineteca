import Foundation

protocol HomePresentationLogic {
    func presentFetchContent(response: HomeModels.FetchContent.Response)
    func presentLoading()
    func presentWatchTrailer(response: HomeModels.WatchTrailer.Response)
}

final class HomePresenter {
    weak var view: HomeDisplayLogic?
}

extension HomePresenter: HomePresentationLogic {
    func presentFetchContent(response: HomeModels.FetchContent.Response) {
        switch response {
        case let .content(featured, nowPlaying, trending, topRated, genreFilter):
            view?.displayFetchContent(
                viewModel: .content(
                    HomeModels.FetchContent.ViewModel.Content(
                        featured: makeFeaturedViewModel(from: featured),
                        genreFilter: GenreFilterViewModel(
                            options: [Strings.HomeScene.GenreFilter.all] + genreFilter.genres.map(\.name),
                            selectedIndex: genreFilter.selectedIndex
                        ),
                        nowPlaying: nowPlaying.map { makeCardViewModel(from: $0) },
                        trending: trending.map { makeCardViewModel(from: $0, isTrending: true) },
                        topRated: topRated.map { makeCardViewModel(from: $0) }
                    )
                )
            )
        case .error:
            view?.displayFetchContent(viewModel: .error)
        }
    }

    func presentLoading() {
        view?.displayLoading()
    }

    func presentWatchTrailer(response: HomeModels.WatchTrailer.Response) {
        switch response {
        case let .success(youtubeKey):
            view?.displayWatchTrailer(viewModel: .success(youtubeKey: youtubeKey))
        case .unavailable:
            view?.displayWatchTrailer(
                viewModel: .unavailable(
                    title: Strings.HomeScene.TrailerUnavailable.title,
                    message: Strings.HomeScene.TrailerUnavailable.message
                )
            )
        }
    }

    private func makeFeaturedViewModel(from movie: Movie) -> FeaturedViewModel {
        FeaturedViewModel(
            movieId: movie.id,
            title: movie.title,
            year: movie.releaseYear,
            rating: formatRating(movie.rating),
            genres: Array(movie.genres.prefix(3)).map(\.name),
            backdropURL: movie.backdropURL
        )
    }

    private func makeCardViewModel(from movie: Movie, isTrending: Bool = false) -> MovieCardViewModel {
        MovieCardViewModel(
            id: movie.id,
            title: movie.title,
            rating: formatRating(movie.rating),
            posterURL: movie.posterURL,
            isTrending: isTrending
        )
    }

    private func formatRating(_ rating: Double) -> String {
        String(format: "%.1f", rating)
    }
}
