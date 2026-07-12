import Foundation

protocol HomePresentationLogic {
    func presentContent(response: HomeModels.FetchContent.Response)
    func presentLoading()
    func presentError(_ error: Error)
}

protocol HomeDisplayLogic: AnyObject {
    func displayContent(viewModel: HomeModels.FetchContent.ViewModel)
    func displayLoading()
    func displayError(viewModel: HomeModels.ErrorState.ViewModel)
}

final class HomePresenter {
    weak var view: HomeDisplayLogic?
}

extension HomePresenter: HomePresentationLogic {
    func presentContent(response: HomeModels.FetchContent.Response) {
        let viewModel = HomeModels.FetchContent.ViewModel(
            featured: makeFeaturedViewModel(from: response.featured),
            nowPlaying: response.nowPlaying.map { makeCardViewModel(from: $0) },
            trending: response.trending.map { makeCardViewModel(from: $0, isTrending: true) },
            topRated: response.topRated.map { makeCardViewModel(from: $0) }
        )
        view?.displayContent(viewModel: viewModel)
    }

    func presentLoading() {
        view?.displayLoading()
    }

    func presentError(_ error: Error) {
        view?.displayError(viewModel: HomeModels.ErrorState.ViewModel())
    }

    private func makeFeaturedViewModel(from movie: Movie) -> FeaturedViewModel {
        FeaturedViewModel(
            title: movie.title,
            year: movie.releaseYear,
            rating: formatRating(movie.rating),
            genres: Array(movie.genres.prefix(3)),
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
