import Foundation

enum HomeModels {
    enum FetchContent {
        struct Request {}

        enum Response {
            case content(
                featured: Movie,
                nowPlaying: [Movie],
                trending: [Movie],
                topRated: [Movie],
                genreFilter: GenreFilter,
                featuredIsInWatchlist: Bool
            )
            case error
        }

        enum ViewModel {
            case content(Content)
            case error

            struct Content {
                let featured: FeaturedViewModel
                let genreFilter: GenreFilterViewModel
                let nowPlaying: [MovieCardViewModel]
                let trending: [MovieCardViewModel]
                let topRated: [MovieCardViewModel]
            }
        }
    }

    enum SelectGenre {
        struct Request {
            let index: Int
        }
    }

    enum DidTapWatchlist {
        struct Request {
            let movieId: Int
            let isInWatchlist: Bool
        }

        enum Response {
            case success(MovieActivity)
            case error
        }

        enum ViewModel {
            case success(isInWatchlist: Bool)
            case error
        }
    }

    enum WatchTrailer {
        struct Request {
            let movieId: Int
        }

        enum Response {
            case success(youtubeKey: String)
            case unavailable
        }

        enum ViewModel {
            case success(youtubeKey: String)
            case unavailable(title: String, message: String)
        }
    }

    struct GenreFilter {
        let genres: [Genre]
        let selectedIndex: Int
    }

    struct GenreFilterViewModel {
        let options: [String]
        let selectedIndex: Int
    }

    struct FeaturedViewModel {
        let movieId: Int
        let title: String
        let year: String
        let rating: String
        let genres: [String]
        let backdropURL: URL?
        let isInWatchlist: Bool
    }

    struct MovieCardViewModel {
        let id: Int
        let title: String
        let rating: String
        let posterURL: URL?
        let isTrending: Bool
    }
}
