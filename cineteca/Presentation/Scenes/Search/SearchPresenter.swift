import Foundation

protocol SearchPresentationLogic {
    func presentMovies(response: SearchModels.Movies.Response)
    func presentLoading(mode: SearchDisplayMode)
    func presentFilters(response: SearchModels.ShowFilters.Response)
}

protocol SearchDisplayLogic: AnyObject {
    func displayMovies(viewModel: SearchModels.Movies.ViewModel)
    func displayLoading(viewModel: SearchModels.Loading.ViewModel)
    func displayFilters(viewModel: SearchModels.ShowFilters.ViewModel)
}

final class SearchPresenter {
    weak var view: SearchDisplayLogic?
}

extension SearchPresenter: SearchPresentationLogic {
    func presentMovies(response: SearchModels.Movies.Response) {
        switch response {
        case let .content(movies, mode):
            view?.displayMovies(viewModel: .content(movies: movies.map(makeGridViewModel), mode: mode))
        case .error:
            view?.displayMovies(viewModel: .error)
        }
    }

    func presentLoading(mode: SearchDisplayMode) {
        view?.displayLoading(viewModel: .init(mode: mode))
    }

    func presentFilters(response: SearchModels.ShowFilters.Response) {
        let currentYear = Calendar.current.component(.year, from: Date())
        let languages = makeLanguageOptions(selectedCode: response.filters.languageCode)

        let viewModel = SearchModels.ShowFilters.ViewModel(
            filters: SearchFiltersViewModel(
                genres: response.genres.map { genre in
                    SearchGenreOptionViewModel(
                        id: genre.id,
                        name: genre.name,
                        isSelected: response.filters.selectedGenreIds.contains(genre.id)
                    )
                },
                yearFrom: response.filters.yearFrom,
                yearTo: response.filters.yearTo,
                minYear: 1990,
                maxYear: currentYear,
                minRating: response.filters.minRating,
                languages: languages,
                selectedLanguageCode: response.filters.languageCode
            )
        )
        view?.displayFilters(viewModel: viewModel)
    }

    private func makeGridViewModel(from movie: Movie) -> SearchMovieGridViewModel {
        SearchMovieGridViewModel(
            id: movie.id,
            title: movie.title,
            year: movie.releaseYear,
            rating: formatRating(movie.rating),
            posterURL: movie.posterURL
        )
    }

    private func formatRating(_ rating: Double) -> String {
        String(format: "%.1f", rating)
    }

    private func makeLanguageOptions(selectedCode: String?) -> [SearchLanguageOptionViewModel] {
        let options: [(String?, String)] = [
            (nil, Strings.SearchScene.Filters.Language.all),
            ("en", Strings.SearchScene.Filters.Language.english),
            ("pt", Strings.SearchScene.Filters.Language.portuguese),
            ("es", Strings.SearchScene.Filters.Language.spanish),
            ("fr", Strings.SearchScene.Filters.Language.french)
        ]

        return options.map { code, name in
            SearchLanguageOptionViewModel(
                code: code,
                name: name,
                isSelected: code == selectedCode
            )
        }
    }
}
