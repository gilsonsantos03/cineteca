import Foundation

enum MovieDetailsModels {
    enum FetchDetails {
        struct Request {
            let movieId: Int
        }

        enum Response {
            case content(movie: MovieDetails, activity: MovieActivity)
            case error
        }

        enum ViewModel {
            case content(Content)
            case error(ErrorViewModel)

            struct Content {
                let movieId: Int
                let title: String
                let overview: String
                let posterURL: URL?
                let backdropURL: URL?
                let metadata: String
                let certification: String?
                let genres: [String]
                let rating: String
                let cast: [CastViewModel]
                let crew: [CrewViewModel]
                let watchProviderGroups: [WatchProviderGroupViewModel]
                let watchOptionsURL: URL?
                let similarMovies: [SimilarMovieViewModel]
                let activity: ActivityViewModel
            }

            struct ErrorViewModel {
                let title: String
                let message: String
            }
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

    enum FetchReview {
        struct Request {
            let movieId: Int
        }

        struct Response {
            let reviewText: String?
        }

        struct ViewModel {
            let reviewText: String?
        }
    }

    enum UpdateActivity {
        struct Request {
            let movieId: Int
            let action: Action
        }

        enum Action {
            case rate(rating: Double, reviewText: String?)
            case favorite(Bool)
            case watchlist(Bool)
        }

        enum Response {
            case content(MovieActivity)
            case error
        }

        enum ViewModel {
            case content(ActivityViewModel)
            case error
        }
    }

    struct CastViewModel {
        let name: String
        let character: String
        let profileURL: URL?
    }

    struct CrewViewModel {
        let name: String
        let role: String
    }

    struct WatchProviderGroupViewModel {
        let title: String
        let providers: [WatchProviderViewModel]
    }

    struct WatchProviderViewModel {
        let name: String
        let logoURL: URL?
    }

    struct SimilarMovieViewModel {
        let id: Int
        let title: String
        let posterURL: URL?
    }

    struct ActivityViewModel {
        let rating: Double?
        let isFavorite: Bool
        let isInWatchlist: Bool
        let canFavorite: Bool
    }
}
