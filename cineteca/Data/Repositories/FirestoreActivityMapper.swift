import FirebaseFirestore
import Foundation

struct FirestoreActivityRecord {
    let metadata: MovieActivityMetadata
    let rating: Double?
    let ratedAt: Date?
    let isFavorite: Bool
    let isInWatchlist: Bool
    let updatedAt: Date
    let reviewText: String
    let reviewDate: Date?

    init(document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        let movieId = Self.intValue(data["movieId"]) ?? Int(document.documentID) ?? 0
        let genres: [Genre] = (data["genres"] as? [[String: Any]] ?? []).compactMap {
            guard let id = Self.intValue($0["id"]), let name = $0["name"] as? String else {
                return nil
            }
            return Genre(id: id, name: name)
        }

        metadata = MovieActivityMetadata(
            movieId: movieId,
            title: data["title"] as? String ?? "",
            posterURL: Self.url(data["posterURL"]),
            backdropURL: Self.url(data["backdropURL"]),
            runtimeMinutes: Self.intValue(data["runtimeMinutes"]),
            releaseYear: data["releaseYear"] as? String,
            genres: genres,
            directorNames: data["directorNames"] as? [String] ?? [],
            actorNames: data["actorNames"] as? [String] ?? []
        )
        rating = data["rating"] as? Double
        ratedAt = (data["ratedAt"] as? Timestamp)?.dateValue()
        isFavorite = data["isFavorite"] as? Bool ?? false
        isInWatchlist = data["isInWatchlist"] as? Bool ?? false
        updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        reviewText = data["reviewText"] as? String ?? ""
        reviewDate = (data["reviewDate"] as? Timestamp)?.dateValue()
    }

    var activity: MovieActivity {
        MovieActivity(
            metadata: metadata,
            rating: rating,
            ratedAt: ratedAt,
            isFavorite: isFavorite,
            isInWatchlist: isInWatchlist,
            updatedAt: updatedAt
        )
    }

    var review: UserReview? {
        guard let rating, !reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return UserReview(
            movieId: metadata.movieId,
            title: metadata.title,
            posterURL: metadata.posterURL,
            rating: rating,
            reviewText: reviewText,
            releaseYear: metadata.releaseYear,
            directorName: metadata.directorNames.first,
            reviewDate: reviewDate ?? ratedAt
        )
    }

    var ratingReview: UserReview? {
        guard let rating else { return nil }
        return UserReview(
            movieId: metadata.movieId,
            title: metadata.title,
            posterURL: metadata.posterURL,
            rating: rating,
            reviewText: reviewText,
            releaseYear: metadata.releaseYear,
            directorName: metadata.directorNames.first,
            reviewDate: reviewDate ?? ratedAt
        )
    }

    static func metadataData(_ metadata: MovieActivityMetadata) -> [String: Any] {
        var data: [String: Any] = [
            "movieId": metadata.movieId,
            "title": metadata.title,
            "genres": metadata.genres.map { ["id": $0.id, "name": $0.name] },
            "directorNames": metadata.directorNames,
            "actorNames": metadata.actorNames
        ]
        if let posterURL = metadata.posterURL?.absoluteString {
            data["posterURL"] = posterURL
        }
        if let backdropURL = metadata.backdropURL?.absoluteString {
            data["backdropURL"] = backdropURL
        }
        if let runtimeMinutes = metadata.runtimeMinutes {
            data["runtimeMinutes"] = runtimeMinutes
        }
        if let releaseYear = metadata.releaseYear {
            data["releaseYear"] = releaseYear
        }
        return data
    }

    private static func url(_ value: Any?) -> URL? {
        guard let value = value as? String else { return nil }
        return URL(string: value)
    }

    private static func intValue(_ value: Any?) -> Int? {
        if let value = value as? Int { return value }
        if let value = value as? Int64 { return Int(value) }
        if let value = value as? NSNumber { return value.intValue }
        return nil
    }
}
