import Foundation

enum MovieRecommendationModels {
    enum Generate {
        struct Request {
            let mode: MovieRecommendationMode
        }

        enum Response {
            case content(recommendation: MovieRecommendation, movie: Movie)
            case error(MovieRecommendationError)
        }

        enum ViewModel {
            case content(ResultViewModel)
            case error(String)
        }

        struct ResultViewModel {
            let movieID: Int
            let title: String
            let year: String
            let rating: String
            let posterURL: URL?
            let explanation: String
        }
    }

    struct SelectedMovieViewModel: Equatable {
        let id: Int
        let title: String
        let backdropURL: URL?
    }
}
