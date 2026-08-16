import Foundation

protocol HomePresentationLogic {
    func presentFetchContent(response: HomeModels.FetchContent.Response)
    func presentLoading()
    func presentWatchTrailer(response: HomeModels.WatchTrailer.Response)
}

protocol HomeDisplayLogic: AnyObject {
    func displayFetchContent(viewModel: HomeModels.FetchContent.ViewModel)
    func displayLoading()
    func displayWatchTrailer(viewModel: HomeModels.WatchTrailer.ViewModel)
}

final class HomePresenter {
    weak var view: HomeDisplayLogic?
}

extension HomePresenter: HomePresentationLogic {
    func presentFetchContent(response: HomeModels.FetchContent.Response) {
        let viewModel: HomeModels.FetchContent.ViewModel = switch response {
        case let .content(featured, nowPlaying, trending, topRated, genreFilter):
            .content(
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
        case .error:
            .error
        }
        view?.displayFetchContent(viewModel: viewModel)
    }

    func presentLoading() {
        view?.displayLoading()
    }

    func presentWatchTrailer(response: HomeModels.WatchTrailer.Response) {
        let viewModel: HomeModels.WatchTrailer.ViewModel = switch response {
        case let .success(youtubeKey):
            .success(youtubeKey: youtubeKey)
        case .unavailable:
            .unavailable(
                title: Strings.HomeScene.TrailerUnavailable.title,
                message: Strings.HomeScene.TrailerUnavailable.message
            )
        }
        view?.displayWatchTrailer(viewModel: viewModel)
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
