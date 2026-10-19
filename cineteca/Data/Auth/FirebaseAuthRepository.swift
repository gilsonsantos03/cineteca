import FirebaseAuth
import Foundation

final class FirebaseAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
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
            withProviderID: credential.providerID,
            idToken: credential.idToken,
            rawNonce: rawNonce
        )

        do {
            let result = try await Auth.auth().signIn(with: firebaseCredential)
            return AuthenticatedUser(
                id: result.user.uid,
                email: result.user.email,
                displayName: result.user.displayName
            )
        } catch {
            throw Self.map(error)
        }
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        guard FirebaseConfiguration.isConfigured else {
            throw AuthenticationError.notConfigured
        }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return Self.makeUser(from: result.user)
        } catch {
            throw Self.map(error)
        }
    }

    func createAccount(email: String, password: String) async throws -> AuthenticatedUser {
        guard FirebaseConfiguration.isConfigured else {
            throw AuthenticationError.notConfigured
        }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return Self.makeUser(from: result.user)
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

    private static func makeUser(from user: FirebaseAuth.User) -> AuthenticatedUser {
        AuthenticatedUser(
            id: user.uid,
            email: user.email,
            displayName: user.displayName
        )
    }
}
