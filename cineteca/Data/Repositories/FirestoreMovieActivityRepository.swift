import FirebaseAuth
import FirebaseFirestore
import Foundation

final class FirestoreMovieActivityRepository: MovieActivityRepositoryProtocol, @unchecked Sendable {
    private let firestore: Firestore

    init(firestore: Firestore = .firestore()) {
        self.firestore = firestore
    }

    func upsertMetadata(_ metadata: MovieActivityMetadata) async throws {
        guard let document = activityDocument(for: metadata.movieId) else { return }
        let snapshot = try await document.getDocument()
        var data = FirestoreActivityRecord.metadataData(metadata)
        if !snapshot.exists {
            data["isFavorite"] = false
            data["isInWatchlist"] = false
            data["updatedAt"] = Timestamp(date: Date())
        }
        try await document.setData(data, merge: true)
    }

    func fetchActivity(for movieId: Int) async throws -> MovieActivity? {
        guard let document = activityDocument(for: movieId) else { return nil }
        let snapshot = try await document.getDocument()
        guard snapshot.exists else { return nil }
        return FirestoreActivityRecord(document: snapshot).activity
    }

    func fetchReview(for movieId: Int) async throws -> String? {
        guard let document = activityDocument(for: movieId) else { return nil }
        let snapshot = try await document.getDocument()
        guard snapshot.exists else { return nil }
        let text = FirestoreActivityRecord(document: snapshot).reviewText
        return text.isEmpty ? nil : text
    }

    func rateMovie(for movieId: Int, rating: Double) async throws -> MovieActivity {
        guard Self.isValidRating(rating) else {
            throw MovieActivityRepositoryError.invalidRating
        }
        guard let document = try await requireActivityDocument(for: movieId) else {
            throw MovieActivityRepositoryError.activityNotFound
        }

        let now = Timestamp(date: Date())
        try await document.updateData([
            "rating": rating,
            "ratedAt": now,
            "updatedAt": now
        ])
        return try await fetchRequiredActivity(for: movieId)
    }

    func unrateMovie(for movieId: Int) async throws -> MovieActivity {
        guard let document = try await requireActivityDocument(for: movieId) else {
            throw MovieActivityRepositoryError.activityNotFound
        }

        let now = Timestamp(date: Date())
        try await document.updateData([
            "rating": FieldValue.delete(),
            "ratedAt": FieldValue.delete(),
            "reviewText": FieldValue.delete(),
            "reviewDate": FieldValue.delete(),
            "isFavorite": false,
            "updatedAt": now
        ])
        return try await fetchRequiredActivity(for: movieId)
    }

    func saveReview(for movieId: Int, rating: Double, text: String) async throws {
        guard Self.isValidRating(rating) else {
            throw MovieActivityRepositoryError.invalidRating
        }
        guard let document = try await requireActivityDocument(for: movieId) else {
            throw MovieActivityRepositoryError.activityNotFound
        }

        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let now = Timestamp(date: Date())
        if normalizedText.isEmpty {
            try await document.updateData([
                "reviewText": FieldValue.delete(),
                "reviewDate": FieldValue.delete(),
                "updatedAt": now
            ])
        } else {
            try await document.updateData([
                "reviewText": normalizedText,
                "reviewDate": now,
                "updatedAt": now
            ])
        }
    }

    func setFavorite(_ isFavorite: Bool, for movieId: Int) async throws -> MovieActivity {
        guard let document = try await requireActivityDocument(for: movieId) else {
            throw MovieActivityRepositoryError.activityNotFound
        }
        let activity = try await fetchRequiredActivity(for: movieId)
        guard activity.isRated else {
            throw MovieActivityRepositoryError.favoriteRequiresRating
        }

        try await document.updateData([
            "isFavorite": isFavorite,
            "updatedAt": Timestamp(date: Date())
        ])
        return try await fetchRequiredActivity(for: movieId)
    }

    func setWatchlist(_ isInWatchlist: Bool, for movieId: Int) async throws -> MovieActivity {
        guard let document = try await requireActivityDocument(for: movieId) else {
            throw MovieActivityRepositoryError.activityNotFound
        }
        try await document.updateData([
            "isInWatchlist": isInWatchlist,
            "updatedAt": Timestamp(date: Date())
        ])
        return try await fetchRequiredActivity(for: movieId)
    }

    func fetchActivities() async throws -> [MovieActivity] {
        guard let userDocument = userDocument else { return [] }
        let snapshot = try await userDocument.collection("activities")
            .order(by: "updatedAt", descending: true)
            .getDocuments()
        return snapshot.documents.map { FirestoreActivityRecord(document: $0).activity }
    }

    func fetchActivityRecords() async throws -> [FirestoreActivityRecord] {
        guard let userDocument = userDocument else { return [] }
        let snapshot = try await userDocument.collection("activities")
            .order(by: "updatedAt", descending: true)
            .getDocuments()
        return snapshot.documents.map(FirestoreActivityRecord.init(document:))
    }

    private var userDocument: DocumentReference? {
        guard let userID = Auth.auth().currentUser?.uid else { return nil }
        return firestore.collection("users").document(userID)
    }

    private func activityDocument(for movieId: Int) -> DocumentReference? {
        userDocument?.collection("activities").document(String(movieId))
    }

    private func requireActivityDocument(for movieId: Int) async throws -> DocumentReference? {
        guard let document = activityDocument(for: movieId) else {
            throw AuthenticationError.userNotAuthenticated
        }
        let snapshot = try await document.getDocument()
        guard snapshot.exists else { return nil }
        return document
    }

    private func fetchRequiredActivity(for movieId: Int) async throws -> MovieActivity {
        guard let activity = try await fetchActivity(for: movieId) else {
            throw MovieActivityRepositoryError.activityNotFound
        }
        return activity
    }

    private static func isValidRating(_ rating: Double) -> Bool {
        rating >= 0.0
            && rating <= 10.0
            && abs(rating.rounded() - rating) < 0.001
    }
}
