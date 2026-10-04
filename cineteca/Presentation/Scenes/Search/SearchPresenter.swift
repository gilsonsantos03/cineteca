import Foundation

protocol SearchPresentationLogic {
    func presentMovies(response: SearchModels.Movies.Response)
    func presentLoading(mode: SearchModels.DisplayMode)
    func presentFilters(response: SearchModels.ShowFilters.Response)
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

    func presentLoading(mode: SearchModels.DisplayMode) {
        view?.displayLoading(viewModel: .init(mode: mode))
    }

    func presentFilters(response: SearchModels.ShowFilters.Response) {
        let currentYear = Calendar.current.component(.year, from: Date())
        let languages = makeLanguageOptions(selectedCode: response.filters.languageCode)

        let viewModel = SearchModels.ShowFilters.ViewModel(
            filters: SearchModels.FiltersViewModel(
                genres: response.genres.map { genre in
                    SearchModels.GenreOptionViewModel(
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

    private func makeGridViewModel(from movie: Movie) -> SearchModels.MovieGridViewModel {
        SearchModels.MovieGridViewModel(
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

    private func makeLanguageOptions(selectedCode: String?) -> [SearchModels.LanguageOptionViewModel] {
        let options: [(String?, String)] = [
            (nil, Strings.SearchScene.Filters.Language.all),
            ("en", Strings.SearchScene.Filters.Language.english),
            ("pt", Strings.SearchScene.Filters.Language.portuguese),
            ("es", Strings.SearchScene.Filters.Language.spanish),
            ("fr", Strings.SearchScene.Filters.Language.french)
        ]

        return options.map { code, name in
            SearchModels.LanguageOptionViewModel(
                code: code,
                name: name,
                isSelected: code == selectedCode
            )
        }
    }
}
