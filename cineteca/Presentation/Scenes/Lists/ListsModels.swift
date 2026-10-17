import Foundation

enum ListsModels {
    enum List: Int, CaseIterable {
        case watchlist
        case favorites
        case rated
    }

    enum FetchContent {
        struct Request {}

        enum Response {
            case content(activities: [MovieActivity], selectedList: List)
            case error
        }

        enum ViewModel {
            case content(Content)
            case error

            struct Content {
                let selectedList: List
                let movies: [MovieCardViewModel]
            }
        }
    }

    enum SelectList {
        struct Request {
            let list: List
        }
    }

    enum RemoveMovie {
        struct Request {
            let movieId: Int
        }

        enum Response {
            case content(activities: [MovieActivity], selectedList: List)
            case error
        }

        enum ViewModel {
            case content(FetchContent.ViewModel.Content)
            case error
        }
    }

    struct MovieCardViewModel {
        let movieId: Int
        let title: String
        let metadata: String
        let genres: [String]
        let posterURL: URL?
        let rating: String?
    }
}
