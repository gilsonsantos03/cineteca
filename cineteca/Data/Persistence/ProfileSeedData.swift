import CoreData
import Foundation

enum ProfileSeedData {
    private struct ReviewSeed {
        let movieId: Int
        let title: String
        let posterPath: String
        let rating: Double
        let reviewText: String
    }

    static func seedIfNeeded(in context: NSManagedObjectContext) throws {
        let request = UserEntity.fetchRequest()
        request.fetchLimit = 1
        if try context.count(for: request) > 0 { return }

        let user = UserEntity(context: context)
        user.username = "@mariadot"
        user.memberSince = makeMemberSinceDate()
        user.avatarImageName = "profile-avatar"
        user.filmsCount = 127
        user.hoursWatched = 318
        user.reviewsCount = 42
        user.favoriteMovieId = 157336
        user.favoriteFilmTitle = "Interstellar"
        user.favoriteBackdropPath = "/rAiYBfKGq16ESwh/5u1cMDouWRUeQ7ZKv2UX7n4.2.jpg"

        let reviews: [ReviewSeed] = [
            ReviewSeed(
                movieId: 872585,
                title: "Oppenheimer",
                posterPath: "/8Gxv8gSfcaaajMBZRduyo6aafLf.jpg",
                rating: 3.5,
                reviewText: "Nolan at his most ambitious. The sound design alone makes this worth the IMAX experience."
            ),
            ReviewSeed(
                movieId: 335984,
                title: "Blade Runner 2049",
                posterPath: "/gajva2L0rPYkEWjzgFlNX5AzULU.jpg",
                rating: 2.5,
                reviewText: "Visually stunning but the pacing drags in the second act. Still a worthy sequel."
            ),
            ReviewSeed(
                movieId: 414906,
                title: "The Batman",
                posterPath: "/b0PlZXz4m5avXvXR4t2h6nfsQdk.jpg",
                rating: 4.0,
                reviewText: "A noir detective story disguised as a superhero film. Pattinson nails the brooding intensity."
            )
        ]

        for (index, review) in reviews.enumerated() {
            let entity = ReviewEntity(context: context)
            entity.movieId = Int32(review.movieId)
            entity.title = review.title
            entity.posterPath = review.posterPath
            entity.rating = review.rating
            entity.reviewText = review.reviewText
            entity.sortOrder = Int16(index)
            entity.user = user
        }

        try context.save()
    }

    private static func makeMemberSinceDate() -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.year = 2023
        components.month = 3
        components.day = 1
        return components.date ?? Date()
    }
}
