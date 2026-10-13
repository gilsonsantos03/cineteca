import CoreData
import Foundation

enum ProfileSeedData {
    private struct ReviewSeed {
        let movieId: Int
        let title: String
        let posterPath: String
        let rating: Double
        let reviewText: String
        let releaseYear: String
        let directorName: String
        let reviewDate: Date
    }

    static func seedIfNeeded(in context: NSManagedObjectContext) throws {
        let request = UserEntity.fetchRequest()
        request.fetchLimit = 1
        if try context.count(for: request) > 0 {
            try backfillProfileFieldsIfNeeded(in: context)
            return
        }

        let user = UserEntity(context: context)
        user.username = "@mariadot"
        user.displayName = "Maria Dot"
        user.bio = "Film lover."
        user.email = "maria.dot@gmail.com"
        user.password = "password123"
        user.memberSince = makeMemberSinceDate()
        user.avatarImageName = "profile-avatar"
        user.filmsCount = 0
        user.hoursWatched = 0
        user.reviewsCount = 0
        user.favoriteMovieId = 0
        user.favoriteFilmTitle = ""

        let reviews: [ReviewSeed] = [
            ReviewSeed(
                movieId: 872585,
                title: "Oppenheimer",
                posterPath: "/8Gxv8gSfcaaajMBZRduyo6aafLf.jpg",
                rating: 7.0,
                reviewText: "Nolan at his most ambitious. The sound design alone makes this worth the IMAX experience.",
                releaseYear: "2023",
                directorName: "Christopher Nolan",
                reviewDate: makeReviewDate(year: 2026, month: 2, day: 2)
            ),
            ReviewSeed(
                movieId: 335984,
                title: "Blade Runner 2049",
                posterPath: "/gajva2L0rPYkEWjzgFlNX5AzULU.jpg",
                rating: 5.0,
                reviewText: "Visually stunning but the pacing drags in the second act. Still a worthy sequel.",
                releaseYear: "2017",
                directorName: "Denis Villeneuve",
                reviewDate: makeReviewDate(year: 2026, month: 1, day: 14)
            ),
            ReviewSeed(
                movieId: 414906,
                title: "The Batman",
                posterPath: "/b0PlZXz4m5avXvXR4t2h6nfsQdk.jpg",
                rating: 8.0,
                reviewText: "A noir detective story disguised as a superhero film. Pattinson nails the brooding intensity.",
                releaseYear: "2022",
                directorName: "Matt Reeves",
                reviewDate: makeReviewDate(year: 2025, month: 12, day: 20)
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
            entity.releaseYear = review.releaseYear
            entity.directorName = review.directorName
            entity.reviewDate = review.reviewDate
            entity.user = user
        }

        try context.save()
    }

    private static func backfillProfileFieldsIfNeeded(in context: NSManagedObjectContext) throws {
        let request = UserEntity.fetchRequest()
        request.fetchLimit = 1
        guard let user = try context.fetch(request).first else { return }

        var needsSave = false
        if user.displayName?.isEmpty != false {
            user.displayName = "Maria Dot"
            needsSave = true
        }
        if user.bio?.isEmpty != false {
            user.bio = "Film lover. 127 films logged."
            needsSave = true
        }
        if user.email?.isEmpty != false {
            user.email = "maria.dot@gmail.com"
            needsSave = true
        }
        if user.password?.isEmpty != false {
            user.password = "password123"
            needsSave = true
        }

        if needsSave {
            try context.save()
        }
    }

    private static func makeMemberSinceDate() -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.year = 2023
        components.month = 3
        components.day = 1
        return components.date ?? Date()
    }

    private static func makeReviewDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.year = year
        components.month = month
        components.day = day
        return components.date ?? Date()
    }
}
