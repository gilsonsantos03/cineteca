import CoreData
import Foundation

final class MovieActivityRepository: MovieActivityRepositoryProtocol, @unchecked Sendable {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func upsertMetadata(_ metadata: MovieActivityMetadata) async throws {
        let context = coreDataStack.viewContext
        try await context.perform {
            let user = try Self.fetchUser(in: context)
            let activity = try Self.fetchActivityEntity(
                for: metadata.movieId,
                user: user,
                in: context
            ) ?? Self.makeActivityEntity(
                for: metadata.movieId,
                user: user,
                in: context
            )

            let isNew = activity.updatedAt == .distantPast
            activity.apply(metadata: metadata)
            if isNew {
                activity.updatedAt = Date()
            }
            try context.save()
        }
    }

    func fetchActivity(for movieId: Int) async throws -> MovieActivity? {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let user = try Self.fetchUser(in: context)
            return try Self.fetchActivityEntity(for: movieId, user: user, in: context)?.toDomain()
        }
    }

    func fetchReview(for movieId: Int) async throws -> String? {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let user = try Self.fetchUser(in: context)
            let request = ReviewEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(
                format: "user == %@ AND movieId == %d",
                user,
                Int32(movieId)
            )
            return try context.fetch(request).first?.reviewText
        }
    }

    func rateMovie(for movieId: Int, rating: Double) async throws -> MovieActivity {
        guard Self.isValidRating(rating) else {
            throw MovieActivityRepositoryError.invalidRating
        }

        return try await updateActivity(for: movieId) { activity in
            activity.rating = rating
            activity.ratedAt = Date()
            activity.updatedAt = Date()
        }
    }

    func saveReview(for movieId: Int, rating: Double, text: String) async throws {
        guard Self.isValidRating(rating) else {
            throw MovieActivityRepositoryError.invalidRating
        }

        let context = coreDataStack.viewContext
        try await context.perform {
            let user = try Self.fetchUser(in: context)
            guard let activity = try Self.fetchActivityEntity(
                for: movieId,
                user: user,
                in: context
            ) else {
                throw MovieActivityRepositoryError.activityNotFound
            }

            let request = ReviewEntity.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(
                format: "user == %@ AND movieId == %d",
                user,
                Int32(movieId)
            )
            let existingReview = try context.fetch(request).first
            let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if normalizedText.isEmpty {
                if let existingReview {
                    context.delete(existingReview)
                    try context.save()
                }
                return
            }

            let review = existingReview ?? ReviewEntity(context: context)
            review.movieId = Int32(movieId)
            review.title = activity.title
            review.posterPath = activity.posterPath
            review.rating = rating
            review.releaseYear = activity.releaseYear
            review.directorName = activity.directorNames.first
            review.reviewDate = activity.ratedAt ?? Date()
            review.reviewText = normalizedText
            review.sortOrder = Int16(max(0, try context.count(for: ReviewEntity.fetchRequest())))
            review.user = user
            try context.save()
        }
    }

    func setFavorite(_ isFavorite: Bool, for movieId: Int) async throws -> MovieActivity {
        return try await updateActivity(for: movieId) { activity in
            guard activity.ratedAt != nil else {
                throw MovieActivityRepositoryError.favoriteRequiresRating
            }
            activity.isFavorite = isFavorite
            activity.updatedAt = Date()
        }
    }

    func setWatchlist(_ isInWatchlist: Bool, for movieId: Int) async throws -> MovieActivity {
        try await updateActivity(for: movieId) { activity in
            activity.isInWatchlist = isInWatchlist
            activity.updatedAt = Date()
        }
    }

    func fetchActivities() async throws -> [MovieActivity] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let user = try Self.fetchUser(in: context)
            let request = MovieActivityEntity.fetchRequest()
            request.predicate = NSPredicate(format: "user == %@", user)
            request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            return try context.fetch(request).map { $0.toDomain() }
        }
    }

    private func updateActivity(
        for movieId: Int,
        mutate: @escaping (MovieActivityEntity) throws -> Void
    ) async throws -> MovieActivity {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let user = try Self.fetchUser(in: context)
            guard let activity = try Self.fetchActivityEntity(
                for: movieId,
                user: user,
                in: context
            ) else {
                throw MovieActivityRepositoryError.activityNotFound
            }

            try mutate(activity)
            try context.save()
            return activity.toDomain()
        }
    }

    private static func fetchUser(in context: NSManagedObjectContext) throws -> UserEntity {
        try ProfileSeedData.seedIfNeeded(in: context)
        let request = UserEntity.fetchRequest()
        request.fetchLimit = 1
        guard let user = try context.fetch(request).first else {
            throw MovieActivityRepositoryError.activityNotFound
        }
        return user
    }

    private static func fetchActivityEntity(
        for movieId: Int,
        user: UserEntity,
        in context: NSManagedObjectContext
    ) throws -> MovieActivityEntity? {
        let request = MovieActivityEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "user == %@ AND movieId == %d",
            user,
            Int32(movieId)
        )
        return try context.fetch(request).first
    }

    private static func makeActivityEntity(
        for movieId: Int,
        user: UserEntity,
        in context: NSManagedObjectContext
    ) -> MovieActivityEntity {
        let activity = MovieActivityEntity(context: context)
        activity.movieId = Int32(movieId)
        activity.title = ""
        activity.rating = -1
        activity.isFavorite = false
        activity.isInWatchlist = false
        activity.updatedAt = .distantPast
        activity.user = user
        return activity
    }

    private static func isValidRating(_ rating: Double) -> Bool {
        rating >= 0.0
            && rating <= 10.0
            && abs(rating.rounded() - rating) < 0.001
    }
}
