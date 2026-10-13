import Foundation

struct MovieActivityMetadata: Sendable, Equatable {
    let movieId: Int
    let title: String
    let posterURL: URL?
    let backdropURL: URL?
    let runtimeMinutes: Int?
    let releaseYear: String?
    let genres: [Genre]
    let directorNames: [String]
    let actorNames: [String]
}

struct MovieActivity: Sendable, Equatable {
    let metadata: MovieActivityMetadata
    let rating: Double?
    let ratedAt: Date?
    let isFavorite: Bool
    let isInWatchlist: Bool
    let updatedAt: Date

    var isRated: Bool {
        rating != nil && ratedAt != nil
    }
}
