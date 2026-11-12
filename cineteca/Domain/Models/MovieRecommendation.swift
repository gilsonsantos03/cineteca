import Foundation

enum MovieRecommendationMode: Sendable, Equatable {
    case moment(String)
    case blend(firstMovieID: Int, secondMovieID: Int)
}

struct MovieRecommendation: Sendable, Equatable {
    let movieID: Int
    let explanation: String
}

enum MovieRecommendationError: Error, Equatable {
    case invalidInput
    case rateLimited
    case unavailable
}
