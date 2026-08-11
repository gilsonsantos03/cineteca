import Foundation

enum MovieDetailsModels {
    enum FetchDetails {
        struct Request {
            let movieId: Int
        }

        struct Response {
            let movie: MovieDetails
        }

        struct ViewModel {
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
            let watchProviders: [WatchProviderViewModel]
            let similarMovies: [SimilarMovieViewModel]
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

    enum ErrorState {
        struct ViewModel {
            let title: String
            let message: String
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

    struct WatchProviderViewModel {
        let name: String
        let logoURL: URL?
    }

    struct SimilarMovieViewModel {
        let id: Int
        let title: String
        let posterURL: URL?
    }
}
