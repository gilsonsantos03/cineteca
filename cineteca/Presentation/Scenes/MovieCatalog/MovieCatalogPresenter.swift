import Foundation

protocol MovieCatalogPresentationLogic {
    func presentFetchContent(response: MovieCatalogModels.FetchContent.Response)
    func presentFetchNextPage(response: MovieCatalogModels.FetchNextPage.Response)
    func presentLoading()
    func presentLoadingNextPage()
}

final class MovieCatalogPresenter {
    weak var view: MovieCatalogDisplayLogic?
}

extension MovieCatalogPresenter: MovieCatalogPresentationLogic {
    func presentFetchContent(response: MovieCatalogModels.FetchContent.Response) {
        switch response {
        case let .content(page, genres):
            let sortedGenres = genres.sorted { $0.name < $1.name }
            view?.displayFetchContent(
                viewModel: .content(
                    .init(
                        movies: page.movies.map(makeMovieCardViewModel),
                        hasMorePages: page.hasMorePages,
                        genreFilter: .init(
                            options: [Strings.HomeScene.GenreFilter.all] + sortedGenres.map(\.name),
                            genreIDs: [nil] + sortedGenres.map { $0.id }
                        )
                    )
                )
            )
        case .error:
            view?.displayFetchContent(viewModel: .error)
        }
    }

    func presentFetchNextPage(response: MovieCatalogModels.FetchNextPage.Response) {
        switch response {
        case let .content(page):
            view?.displayFetchNextPage(
                viewModel: .content(
                    .init(
                        movies: page.movies.map(makeMovieCardViewModel),
                        hasMorePages: page.hasMorePages
                    )
                )
            )
        case .error:
            view?.displayFetchNextPage(viewModel: .error)
        }
    }

    func presentLoading() {
        view?.displayLoading()
    }

    func presentLoadingNextPage() {
        view?.displayLoadingNextPage()
    }

    private func makeMovieCardViewModel(from movie: Movie) -> MovieCatalogModels.MovieCardViewModel {
        MovieCatalogModels.MovieCardViewModel(
            id: movie.id,
            title: movie.title,
            year: movie.releaseYear,
            rating: String(format: "%.1f", movie.rating),
            posterURL: movie.posterURL,
            genreIDs: movie.genres.map(\.id)
        )
    }
}
