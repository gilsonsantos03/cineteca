import CoreData
import Foundation

final class UserRepository: UserRepositoryProtocol {
    private let coreDataStack: CoreDataStack
    private let activityRepository: MovieActivityRepositoryProtocol

    init(
        coreDataStack: CoreDataStack,
        activityRepository: MovieActivityRepositoryProtocol
    ) {
        self.coreDataStack = coreDataStack
        self.activityRepository = activityRepository
    }

    func fetchCurrentUser() async throws -> User {
        let context = coreDataStack.viewContext
        let user = try await context.perform {
            try ProfileSeedData.seedIfNeeded(in: context)
            return try Self.fetchUserEntity(in: context).toDomain()
        }
        return try await applyActivities(to: user)
    }

    func updateProfile(_ update: UserProfileUpdate) async throws -> User {
        let context = coreDataStack.viewContext
        let user = try await context.perform {
            let entity = try Self.fetchUserEntity(in: context)
            entity.displayName = update.displayName
            entity.bio = update.bio
            try context.save()
            return entity.toDomain()
        }
        return try await applyActivities(to: user)
    }

    func updatePassword(_ update: UserPasswordUpdate) async throws {
        let context = coreDataStack.viewContext
        try await context.perform {
            let entity = try Self.fetchUserEntity(in: context)
            guard entity.password == update.currentPassword else {
                throw UserRepositoryError.invalidCurrentPassword
            }
            entity.password = update.newPassword
            try context.save()
        }
    }

    private static func fetchUserEntity(in context: NSManagedObjectContext) throws -> UserEntity {
        let request = UserEntity.fetchRequest()
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else {
            throw UserRepositoryError.userNotFound
        }
        return entity
    }

    private func applyActivities(to user: User) async throws -> User {
        let activities = try await activityRepository.fetchActivities()
        let ratedActivities = activities.filter(\.isRated)
        let reviews = Self.mergeRatedActivities(
            into: user.reviews,
            ratedActivities: ratedActivities
        )
        let totalRuntime = ratedActivities.reduce(0) { total, activity in
            total + (activity.metadata.runtimeMinutes ?? 0)
        }
        let favoriteActivity = activities
            .filter(\.isFavorite)
            .max { $0.updatedAt < $1.updatedAt }

        let favoriteFilm = favoriteActivity.map {
            UserFavoriteFilm(
                movieId: $0.metadata.movieId,
                title: $0.metadata.title,
                backdropURL: $0.metadata.backdropURL
            )
        }
        let stats = UserStats(
            filmsCount: ratedActivities.count,
            hoursWatched: Int((Double(totalRuntime) / 60.0).rounded()),
            reviewsCount: reviews.count
        )

        return user.applying(
            favoriteFilm: favoriteFilm,
            stats: stats,
            reviews: reviews
        )
    }

    private static func mergeRatedActivities(
        into reviews: [UserReview],
        ratedActivities: [MovieActivity]
    ) -> [UserReview] {
        let reviewedMovieIDs = Set(reviews.map(\.movieId))
        let ratingOnlyReviews = ratedActivities
            .filter { !reviewedMovieIDs.contains($0.metadata.movieId) }
            .compactMap { activity -> UserReview? in
                guard let rating = activity.rating else { return nil }
                return UserReview(
                    movieId: activity.metadata.movieId,
                    title: activity.metadata.title,
                    posterURL: activity.metadata.posterURL,
                    rating: rating,
                    reviewText: "",
                    releaseYear: activity.metadata.releaseYear,
                    directorName: activity.metadata.directorNames.first,
                    reviewDate: activity.ratedAt
                )
            }

        return (reviews + ratingOnlyReviews).sorted {
            ($0.reviewDate ?? .distantPast) > ($1.reviewDate ?? .distantPast)
        }
    }
}

enum UserRepositoryError: Error {
    case userNotFound
    case invalidCurrentPassword
}
