import Foundation

enum SearchModels {
    enum LoadContent {
        struct Request {}
    }

    enum Movies {
        enum Response {
            case content(movies: [Movie], mode: DisplayMode)
            case error
        }

        enum ViewModel {
            case content(movies: [MovieGridViewModel], mode: DisplayMode)
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
            let mode: DisplayMode
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
            let filters: FiltersViewModel
        }
    }

    enum DisplayMode {
        case suggested
        case results
    }

    struct MovieGridViewModel {
        let id: Int
        let title: String
        let year: String
        let rating: String
        let posterURL: URL?
    }

    struct FiltersViewModel {
        let genres: [GenreOptionViewModel]
        let yearFrom: Int
        let yearTo: Int
        let minYear: Int
        let maxYear: Int
        let minRating: Int
        let languages: [LanguageOptionViewModel]
        let selectedLanguageCode: String?
    }

    struct GenreOptionViewModel {
        let id: Int
        let name: String
        let isSelected: Bool
    }

    struct LanguageOptionViewModel {
        let code: String?
        let name: String
        let isSelected: Bool
    }
}
