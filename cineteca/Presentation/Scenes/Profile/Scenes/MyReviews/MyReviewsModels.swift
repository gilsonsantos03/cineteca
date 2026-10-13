import Foundation

enum MyReviewsModels {
    enum FetchReviews {
        struct Request {}

        enum Response {
            case content(User)
            case error
        }

        enum ViewModel {
            case content(Content)
            case error

            struct Content {
                let subtitle: String
                let reviews: [ReviewCardViewModel]
            }
        }
    }

    enum UpdateReview {
        struct Request {
            let metadata: MovieActivityMetadata
            let rating: Double
            let reviewText: String?
        }

        enum Response {
            case content(User)
            case error
        }

        enum ViewModel {
            case content(FetchReviews.ViewModel.Content)
            case error
        }
    }

    struct ReviewCardViewModel {
        let movieId: Int
        let title: String
        let metadata: String
        let releaseYear: String?
        let directorName: String?
        let posterURL: URL?
        let rating: Double
        let reviewText: String
        let dateText: String
    }
}
