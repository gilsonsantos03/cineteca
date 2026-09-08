import Foundation

struct UserProfileUpdate: Sendable {
    let displayName: String
    let bio: String
}

struct UserPasswordUpdate: Sendable {
    let currentPassword: String
    let newPassword: String
}

protocol UserRepositoryProtocol: Sendable {
    func fetchCurrentUser() async throws -> User
    func updateProfile(_ update: UserProfileUpdate) async throws -> User
    func updatePassword(_ update: UserPasswordUpdate) async throws
}
