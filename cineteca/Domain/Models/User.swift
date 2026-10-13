import Foundation

struct User: Sendable {
    let username: String
    let displayName: String
    let bio: String
    let email: String
    let memberSince: Date
    let avatarImageName: String?
    let favoriteFilm: UserFavoriteFilm?
    let stats: UserStats
    let reviews: [UserReview]
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
    let releaseYear: String?
    let directorName: String?
    let reviewDate: Date?
}

extension User {
    func applying(
        favoriteFilm: UserFavoriteFilm?,
        stats: UserStats
    ) -> User {
        User(
            username: username,
            displayName: displayName,
            bio: bio,
            email: email,
            memberSince: memberSince,
            avatarImageName: avatarImageName,
            favoriteFilm: favoriteFilm,
            stats: stats,
            reviews: reviews,
            recentReviews: recentReviews
        )
    }
}
