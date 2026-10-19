import FirebaseAuth
import FirebaseFirestore
import Foundation

final class FirestoreUserRepository: UserRepositoryProtocol, @unchecked Sendable {
    private static let profileErrorDomain = "Cineteca.UserProfile"
    private static let usernameTakenErrorCode = 1

    private let firestore: Firestore
    private let activityRepository: FirestoreMovieActivityRepository

    init(
        firestore: Firestore = .firestore(),
        activityRepository: FirestoreMovieActivityRepository
    ) {
        self.firestore = firestore
        self.activityRepository = activityRepository
    }

    func fetchCurrentUser() async throws -> User {
        guard let firebaseUser = Auth.auth().currentUser else {
            return Self.guestUser
        }

        let document = firestore.collection("users").document(firebaseUser.uid)
        let snapshot = try await document.getDocument()
        if !snapshot.exists {
            try await claimUsername(
                Self.defaultUsername(for: firebaseUser),
                for: document,
                userID: firebaseUser.uid,
                profileData: Self.initialData(for: firebaseUser)
            )
        } else {
            let normalizedUsername = UsernamePolicy.normalized(
                snapshot.data()?["username"] as? String ?? ""
            )
            let storedUsername = normalizedUsername.isEmpty
                ? Self.defaultUsername(for: firebaseUser)
                : normalizedUsername
            try await claimUsername(
                storedUsername,
                for: document,
                userID: firebaseUser.uid,
                profileData: ["username": storedUsername]
            )
        }

        let profile = try await document.getDocument().data() ?? [:]
        let records = try await activityRepository.fetchActivityRecords()
        return Self.makeUser(
            profile: profile,
            activities: records,
            firebaseUser: firebaseUser
        )
    }

    func createProfile(username: String) async throws -> User {
        guard let firebaseUser = Auth.auth().currentUser else {
            throw AuthenticationError.userNotAuthenticated
        }

        let username = try UsernamePolicy.validate(username)
        let document = firestore.collection("users").document(firebaseUser.uid)
        let snapshot = try await document.getDocument()
        guard !snapshot.exists else {
            return try await fetchCurrentUser()
        }

        var profileData = Self.initialData(for: firebaseUser)
        profileData["username"] = username
        try await claimUsername(
            username,
            for: document,
            userID: firebaseUser.uid,
            profileData: profileData
        )
        return try await fetchCurrentUser()
    }

    func updateProfile(_ update: UserProfileUpdate) async throws -> User {
        guard let firebaseUser = Auth.auth().currentUser else {
            throw AuthenticationError.userNotAuthenticated
        }

        let username = try UsernamePolicy.validate(update.username)
        var data: [String: Any] = [
            "username": username,
            "displayName": update.displayName,
            "bio": update.bio,
        ]
        if let favoriteFilm = update.favoriteFilm {
            data["favoriteMovieId"] = favoriteFilm.movieId
            data["favoriteFilmTitle"] = favoriteFilm.title
            if let backdropURL = favoriteFilm.backdropURL?.absoluteString {
                data["favoriteBackdropURL"] = backdropURL
            } else {
                data["favoriteBackdropURL"] = NSNull()
            }
        } else {
            data["favoriteMovieId"] = 0
            data["favoriteFilmTitle"] = ""
            data["favoriteBackdropURL"] = NSNull()
        }
        try await claimUsername(
            username,
            for: firestore.collection("users").document(firebaseUser.uid),
            userID: firebaseUser.uid,
            profileData: data
        )
        return try await fetchCurrentUser()
    }

    func updatePassword(_ update: UserPasswordUpdate) async throws {
        throw AuthenticationError.unavailable
    }

    func deleteCurrentUserData() async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw AuthenticationError.userNotAuthenticated
        }

        let userDocument = firestore.collection("users").document(userID)
        let userSnapshot = try await userDocument.getDocument()
        let normalizedUsername = UsernamePolicy.normalized(
            userSnapshot.data()?["username"] as? String ?? ""
        )
        let username = normalizedUsername.isEmpty ? nil : normalizedUsername
        let activities = try await userDocument.collection("activities").getDocuments()
        let batch = firestore.batch()
        activities.documents.forEach { batch.deleteDocument($0.reference) }
        if let username {
            batch.deleteDocument(firestore.collection("usernames").document(username))
        }
        batch.deleteDocument(userDocument)
        try await batch.commit()
    }

    private func claimUsername(
        _ username: String,
        for userDocument: DocumentReference,
        userID: String,
        profileData: [String: Any]
    ) async throws {
        let usernameDocument = firestore.collection("usernames").document(username)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            firestore.runTransaction({ transaction, errorPointer in
                do {
                    let userSnapshot = try transaction.getDocument(userDocument)
                    let previousUsername = userSnapshot.data().flatMap {
                        UsernamePolicy.normalized($0["username"] as? String ?? "")
                    }
                    let usernameSnapshot = try transaction.getDocument(usernameDocument)
                    if usernameSnapshot.exists,
                       let ownerID = usernameSnapshot.data()?["uid"] as? String,
                       ownerID != userID {
                        errorPointer?.pointee = NSError(
                            domain: Self.profileErrorDomain,
                            code: Self.usernameTakenErrorCode
                        )
                        return nil
                    }

                    transaction.setData(
                        ["uid": userID, "username": username],
                        forDocument: usernameDocument,
                        merge: true
                    )
                    if let previousUsername, previousUsername != username {
                        let previousDocument = self.firestore.collection("usernames").document(previousUsername)
                        transaction.deleteDocument(previousDocument)
                    }
                    transaction.setData(profileData, forDocument: userDocument, merge: true)
                    return nil
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }, completion: { _, error in
                if let error {
                    let nsError = error as NSError
                    if nsError.domain == Self.profileErrorDomain,
                       nsError.code == Self.usernameTakenErrorCode {
                        continuation.resume(throwing: UserProfileError.usernameTaken)
                    } else {
                        continuation.resume(throwing: error)
                    }
                } else {
                    continuation.resume()
                }
            })
        }
    }

    private static func makeUser(
        profile: [String: Any],
        activities: [FirestoreActivityRecord],
        firebaseUser: FirebaseAuth.User
    ) -> User {
        let reviews = activities
            .compactMap(\.ratingReview)
            .sorted { ($0.reviewDate ?? .distantPast) > ($1.reviewDate ?? .distantPast) }
        let ratedActivities = activities.filter { $0.rating != nil && $0.ratedAt != nil }
        let runtimeMinutes = ratedActivities.reduce(0) {
            $0 + ($1.metadata.runtimeMinutes ?? 0)
        }

        let favoriteFilm: UserFavoriteFilm?
        if let movieID = intValue(profile["favoriteMovieId"]), movieID > 0 {
            favoriteFilm = UserFavoriteFilm(
                movieId: movieID,
                title: profile["favoriteFilmTitle"] as? String ?? "",
                backdropURL: url(profile["favoriteBackdropURL"])
            )
        } else {
            favoriteFilm = nil
        }

        return User(
            username: Self.displayUsername(
                {
                    let normalizedUsername = UsernamePolicy.normalized(
                        profile["username"] as? String ?? ""
                    )
                    return normalizedUsername.isEmpty
                        ? Self.defaultUsername(for: firebaseUser)
                        : normalizedUsername
                }()
            ),
            displayName: profile["displayName"] as? String ?? firebaseUser.displayName ?? "",
            bio: profile["bio"] as? String ?? "",
            email: profile["email"] as? String ?? firebaseUser.email ?? "",
            memberSince: date(profile["memberSince"]) ?? Date(),
            avatarImageName: profile["avatarImageName"] as? String,
            favoriteFilm: favoriteFilm,
            stats: UserStats(
                filmsCount: ratedActivities.count,
                hoursWatched: Int((Double(runtimeMinutes) / 60.0).rounded()),
                reviewsCount: reviews.count
            ),
            reviews: reviews,
            recentReviews: Array(reviews.prefix(3)),
            isAuthenticated: true
        )
    }

    private static func initialData(for user: FirebaseAuth.User) -> [String: Any] {
        [
            "username": defaultUsername(for: user),
            "displayName": user.displayName ?? "",
            "bio": "",
            "email": user.email ?? "",
            "memberSince": Timestamp(date: Date()),
            "avatarImageName": NSNull(),
            "favoriteMovieId": 0,
            "favoriteFilmTitle": "",
            "favoriteBackdropURL": NSNull()
        ]
    }

    private static var guestUser: User {
        User(
            username: "",
            displayName: "",
            bio: "",
            email: "",
            memberSince: Date(),
            avatarImageName: nil,
            favoriteFilm: nil,
            stats: UserStats(filmsCount: 0, hoursWatched: 0, reviewsCount: 0),
            reviews: [],
            recentReviews: [],
            isAuthenticated: false
        )
    }

    private static func date(_ value: Any?) -> Date? {
        (value as? Timestamp)?.dateValue()
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

    private static func defaultUsername(for user: FirebaseAuth.User) -> String {
        let username = UsernamePolicy.normalized(user.uid.prefix(8).description)
        return username.isEmpty ? "user\(user.uid.prefix(8))" : username
    }

    private static func displayUsername(_ value: String) -> String {
        "@\(value)"
    }
}
