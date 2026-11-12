import FirebaseAuth
import FirebaseFirestore
import Foundation

final class FirebaseAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    var state: AuthState {
        guard FirebaseConfiguration.isConfigured else { return .guest }
        guard let user = Auth.auth().currentUser else { return .guest }
        return .authenticated(userID: user.uid)
    }

    func signIn(with credential: AuthProviderCredential) async throws -> AuthenticatedUser {
        guard FirebaseConfiguration.isConfigured else {
            throw AuthenticationError.notConfigured
        }
        guard let rawNonce = credential.rawNonce else {
            throw AuthenticationError.invalidCredential
        }

        let firebaseCredential = OAuthProvider.credential(
            providerID: .custom(credential.providerID),
            idToken: credential.idToken,
            rawNonce: rawNonce
        )

        do {
            let auth = Auth.auth()
            let result = try await auth.signIn(with: firebaseCredential)
            try await createProfileIfNeeded(username: nil)
            return Self.makeUser(from: result.user)
        } catch {
            throw Self.map(error)
        }
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        guard FirebaseConfiguration.isConfigured else {
            throw AuthenticationError.notConfigured
        }

        do {
            let auth = Auth.auth()
            let result = try await auth.signIn(withEmail: email, password: password)
            try await createProfileIfNeeded(username: nil)
            return Self.makeUser(from: result.user)
        } catch {
            throw Self.map(error)
        }
    }

    func createAccount(
        email: String,
        password: String,
        username: String?
    ) async throws -> AuthenticatedUser {
        guard FirebaseConfiguration.isConfigured else {
            throw AuthenticationError.notConfigured
        }

        do {
            let auth = Auth.auth()
            let result = try await auth.createUser(withEmail: email, password: password)
            do {
                try await createProfileIfNeeded(username: username)
            } catch {
                await rollbackNewAccount(result.user)
                throw error
            }
            return Self.makeUser(from: result.user)
        } catch {
            throw Self.map(error)
        }
    }

    func createProfileIfNeeded(username: String?) async throws {
        guard FirebaseConfiguration.isConfigured else {
            throw AuthenticationError.notConfigured
        }
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotAuthenticated
        }

        do {
            let document = Firestore.firestore().collection("users").document(user.uid)
            let snapshot = try await document.getDocument()
            guard !snapshot.exists else { return }

            let profileUsername: String
            if let username, !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                profileUsername = username
            } else {
                profileUsername = String(user.uid.prefix(8)).lowercased()
            }
            _ = try await userRepository.createProfile(username: profileUsername)
        } catch {
            throw Self.map(error)
        }
    }

    func sendPasswordReset(to email: String) async throws {
        guard FirebaseConfiguration.isConfigured else {
            throw AuthenticationError.notConfigured
        }

        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw Self.map(error)
        }
    }

    func signOut() throws {
        guard FirebaseConfiguration.isConfigured else {
            throw AuthenticationError.notConfigured
        }
        do {
            try Auth.auth().signOut()
        } catch {
            throw Self.map(error)
        }
    }

    func deleteAccount() async throws {
        guard FirebaseConfiguration.isConfigured else {
            throw AuthenticationError.notConfigured
        }
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.userNotAuthenticated
        }

        do {
            try await user.delete()
        } catch {
            throw Self.map(error)
        }
    }

    private static func map(_ error: Error) -> AuthenticationError {
        if let authenticationError = error as? AuthenticationError {
            return authenticationError
        }
        let nsError = error as NSError
        if nsError.code == AuthErrorCode.invalidEmail.rawValue {
            return .invalidEmail
        }
        if nsError.code == AuthErrorCode.missingEmail.rawValue {
            return .invalidEmail
        }
        if nsError.code == AuthErrorCode.weakPassword.rawValue {
            return .weakPassword
        }
        if nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
            return .emailAlreadyInUse
        }
        if nsError.code == AuthErrorCode.wrongPassword.rawValue
            || nsError.code == AuthErrorCode.userNotFound.rawValue {
            return .invalidCredentials
        }
        if nsError.code == AuthErrorCode.networkError.rawValue {
            return .networkError
        }
        if nsError.code == AuthErrorCode.tooManyRequests.rawValue {
            return .tooManyRequests
        }
        if nsError.code == AuthErrorCode.userDisabled.rawValue {
            return .userDisabled
        }
        if nsError.code == AuthErrorCode.operationNotAllowed.rawValue {
            return .operationNotAllowed
        }
        if nsError.code == AuthErrorCode.invalidCredential.rawValue {
            return .invalidCredential
        }
        if nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
            return .deletionRequiresRecentLogin
        }
        return .underlying(message: error.localizedDescription)
    }

    private func rollbackNewAccount(_ user: FirebaseAuth.User) async {
        try? await userRepository.deleteCurrentUserData()
        try? await user.delete()
    }

    private static func makeUser(from user: FirebaseAuth.User) -> AuthenticatedUser {
        AuthenticatedUser(
            id: user.uid,
            email: user.email,
            displayName: user.displayName
        )
    }
}
