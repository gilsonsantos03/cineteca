import Foundation

protocol MovieActivityRepositoryProtocol: Sendable {
    func resetSessionData() throws
    func upsertMetadata(_ metadata: MovieActivityMetadata) async throws
    func fetchActivity(for movieId: Int) async throws -> MovieActivity?
    func fetchReview(for movieId: Int) async throws -> String?
    func rateMovie(for movieId: Int, rating: Double) async throws -> MovieActivity
    func unrateMovie(for movieId: Int) async throws -> MovieActivity
    func saveReview(for movieId: Int, rating: Double, text: String) async throws
    func setFavorite(_ isFavorite: Bool, for movieId: Int) async throws -> MovieActivity
    func setWatchlist(_ isInWatchlist: Bool, for movieId: Int) async throws -> MovieActivity
    func fetchActivities() async throws -> [MovieActivity]
}

enum MovieActivityRepositoryError: Error {
    case activityNotFound
    case favoriteRequiresRating
    case invalidRating
}
