import Foundation

struct SearchModels {
    enum LoadContent {
        struct Request {}
    }

    enum Movies {
        enum Response {
            case content(movies: [Movie], mode: SearchDisplayMode)
            case error
        }

        enum ViewModel {
            case content(movies: [SearchMovieGridViewModel], mode: SearchDisplayMode)
            case error
        }
    }

    enum Search {
        struct Request {
            let query: String
        }
    }

    enum Loading {
        struct ViewModel {
            let mode: SearchDisplayMode
        }
    }

    enum UpdateFilters {
        struct Request {
            let filters: SearchFilters
        }
    }

    enum ShowFilters {
        struct Response {
            let filters: SearchFilters
            let genres: [Genre]
        }

        struct ViewModel {
            let filters: SearchFiltersViewModel
        }
    }
}

enum SearchDisplayMode {
    case suggested
    case results
}

struct SearchMovieGridViewModel {
    let id: Int
    let title: String
    let year: String
    let rating: String
    let posterURL: URL?
}

struct SearchFiltersViewModel {
    let genres: [SearchGenreOptionViewModel]
    let yearFrom: Int
    let yearTo: Int
    let minYear: Int
    let maxYear: Int
    let minRating: Int
    let languages: [SearchLanguageOptionViewModel]
    let selectedLanguageCode: String?
}

struct SearchGenreOptionViewModel {
    let id: Int
    let name: String
    let isSelected: Bool
}

struct SearchLanguageOptionViewModel {
    let code: String?
    let name: String
    let isSelected: Bool
}
