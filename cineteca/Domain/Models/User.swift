import Foundation

struct User: Sendable {
    let username: String
    let memberSince: Date
    let avatarImageName: String?
    let favoriteFilm: UserFavoriteFilm?
    let stats: UserStats
    let recentReviews: [UserReview]
}

struct UserFavoriteFilm: Sendable {
    let movieId: Int
    let title: String
    let backdropURL: URL?
}

struct UserStats: Sendable {
    let filmsCount: Int
    let hoursWatched: Int
    let reviewsCount: Int
}

struct UserReview: Sendable {
    let movieId: Int
    let title: String
    let posterURL: URL?
    let rating: Double
    let reviewText: String
}
