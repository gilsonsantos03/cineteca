import CoreData

@objc(UserEntity)
final class UserEntity: NSManagedObject {
    @NSManaged var username: String
    @NSManaged var displayName: String?
    @NSManaged var bio: String?
    @NSManaged var email: String?
    @NSManaged var password: String?
    @NSManaged var memberSince: Date
    @NSManaged var avatarImageName: String?
    @NSManaged var filmsCount: Int32
    @NSManaged var hoursWatched: Int32
    @NSManaged var reviewsCount: Int32
    @NSManaged var favoriteMovieId: Int32
    @NSManaged var favoriteFilmTitle: String
    @NSManaged var favoriteBackdropPath: String?
    @NSManaged var reviews: NSOrderedSet?
}

extension UserEntity {
    @nonobjc static func fetchRequest() -> NSFetchRequest<UserEntity> {
        NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    func toDomain() -> User {
        let reviewEntities = (reviews?.array as? [ReviewEntity]) ?? []
        let sortedReviews = reviewEntities.sorted { $0.sortOrder < $1.sortOrder }

        let favoriteFilm: UserFavoriteFilm?
        if favoriteMovieId > 0 {
            favoriteFilm = UserFavoriteFilm(
                movieId: Int(favoriteMovieId),
                title: favoriteFilmTitle,
                backdropURL: favoriteBackdropPath.flatMap { URL(string: TMDBImage.backdropBaseURL + $0) }
            )
        } else {
            favoriteFilm = nil
        }

        return User(
            username: username,
            displayName: displayName ?? "",
            bio: bio ?? "",
            email: email ?? "",
            memberSince: memberSince,
            avatarImageName: avatarImageName,
            favoriteFilm: favoriteFilm,
            stats: UserStats(
                filmsCount: Int(filmsCount),
                hoursWatched: Int(hoursWatched),
                reviewsCount: Int(reviewsCount)
            ),
            recentReviews: sortedReviews.map { $0.toDomain() }
        )
    }
}
