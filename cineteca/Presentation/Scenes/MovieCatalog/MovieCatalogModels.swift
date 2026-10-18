import Foundation

enum MovieCatalogModels {
    enum FetchContent {
        struct Request {}

        enum Response {
            case content(page: MovieCollectionPage, genres: [Genre])
            case error
        }

        enum ViewModel {
            case content(Content)
            case error

            struct Content {
                let movies: [MovieCardViewModel]
                let hasMorePages: Bool
                let genreFilter: GenreFilterViewModel
            }
        }
    }

    enum FetchNextPage {
        struct Request {}

        enum Response {
            case content(MovieCollectionPage)
            case error
        }

        enum ViewModel {
            case content(Content)
            case error

            struct Content {
                let movies: [MovieCardViewModel]
                let hasMorePages: Bool
            }
        }
    }

    struct MovieCardViewModel {
        let id: Int
        let title: String
        let year: String
        let rating: String
        let posterURL: URL?
        let genreIDs: [Int]
    }

    struct GenreFilterViewModel {
        let options: [String]
        let genreIDs: [Int?]
    }
}
