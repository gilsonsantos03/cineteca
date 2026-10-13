import CoreData
import Foundation

@objc(MovieActivityEntity)
final class MovieActivityEntity: NSManagedObject {
    @NSManaged var movieId: Int32
    @NSManaged var title: String
    @NSManaged var posterPath: String?
    @NSManaged var backdropPath: String?
    @NSManaged var runtimeMinutes: Int32
    @NSManaged var releaseYear: String?
    @NSManaged var genresData: String?
    @NSManaged var directorNamesData: String?
    @NSManaged var actorNamesData: String?
    @NSManaged var rating: Double
    @NSManaged var ratedAt: Date?
    @NSManaged var isFavorite: Bool
    @NSManaged var isInWatchlist: Bool
    @NSManaged var updatedAt: Date
    @NSManaged var user: UserEntity?

    var directorNames: [String] {
        Self.decodeNames(directorNamesData)
    }
}

extension MovieActivityEntity {
    @nonobjc static func fetchRequest() -> NSFetchRequest<MovieActivityEntity> {
        NSFetchRequest<MovieActivityEntity>(entityName: "MovieActivityEntity")
    }

    func apply(metadata: MovieActivityMetadata) {
        movieId = Int32(metadata.movieId)
        title = metadata.title
        posterPath = metadata.posterURL?.absoluteString
        backdropPath = metadata.backdropURL?.absoluteString
        runtimeMinutes = Int32(metadata.runtimeMinutes ?? 0)
        releaseYear = metadata.releaseYear
        genresData = Self.encodeGenres(metadata.genres)
        directorNamesData = Self.encodeNames(metadata.directorNames)
        actorNamesData = Self.encodeNames(metadata.actorNames)
    }

    func toDomain() -> MovieActivity {
        let genres = Self.decodeGenres(genresData)
        let metadata = MovieActivityMetadata(
            movieId: Int(movieId),
            title: title,
            posterURL: posterPath.flatMap(URL.init(string:)),
            backdropURL: backdropPath.flatMap(URL.init(string:)),
            runtimeMinutes: runtimeMinutes > 0 ? Int(runtimeMinutes) : nil,
            releaseYear: releaseYear,
            genres: genres,
            directorNames: Self.decodeNames(directorNamesData),
            actorNames: Self.decodeNames(actorNamesData)
        )

        return MovieActivity(
            metadata: metadata,
            rating: ratedAt == nil || rating < 0 ? nil : rating,
            ratedAt: ratedAt,
            isFavorite: isFavorite,
            isInWatchlist: isInWatchlist,
            updatedAt: updatedAt
        )
    }

    private struct GenrePayload: Codable {
        let id: Int
        let name: String
    }

    private static func encodeGenres(_ genres: [Genre]) -> String? {
        let payload = genres.map { GenrePayload(id: $0.id, name: $0.name) }
        guard let data = try? JSONEncoder().encode(payload) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func decodeGenres(_ value: String?) -> [Genre] {
        guard
            let value,
            let data = value.data(using: .utf8),
            let payload = try? JSONDecoder().decode([GenrePayload].self, from: data)
        else {
            return []
        }

        return payload.map { Genre(id: $0.id, name: $0.name) }
    }

    private static func encodeNames(_ names: [String]) -> String? {
        guard let data = try? JSONEncoder().encode(names) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func decodeNames(_ value: String?) -> [String] {
        guard
            let value,
            let data = value.data(using: .utf8),
            let names = try? JSONDecoder().decode([String].self, from: data)
        else {
            return []
        }

        return names
    }
}
