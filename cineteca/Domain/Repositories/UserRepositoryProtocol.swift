import Foundation

struct UserProfileUpdate: Sendable {
    let username: String
    let displayName: String
    let bio: String
    let favoriteFilm: UserFavoriteFilm?
}

enum UserProfileError: LocalizedError, Equatable {
    case invalidUsername
    case usernameTaken

    var errorDescription: String? {
        switch self {
        case .invalidUsername:
            return "Use de 3 a 20 caracteres: letras, números ou _."
        case .usernameTaken:
            return "Esse nome de usuário já está em uso."
        }
    }
}

enum UsernamePolicy {
    static func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "@"))
            .lowercased()
    }

    static func validate(_ value: String) throws -> String {
        let normalized = normalized(value)
        guard normalized.count >= 3,
              normalized.count <= 20,
              normalized.range(of: "^[a-z0-9_]+$", options: .regularExpression) != nil
        else {
            throw UserProfileError.invalidUsername
        }
        return normalized
    }
}

struct UserPasswordUpdate: Sendable {
    let currentPassword: String
    let newPassword: String
}

enum UserRepositoryError: Error {
    case userNotFound
    case invalidCurrentPassword
}

protocol UserRepositoryProtocol: Sendable {
    func fetchCurrentUser() async throws -> User
    func createProfile(username: String) async throws -> User
    func updateProfile(_ update: UserProfileUpdate) async throws -> User
    func updatePassword(_ update: UserPasswordUpdate) async throws
    func deleteCurrentUserData() async throws
}
