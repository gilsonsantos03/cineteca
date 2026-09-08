import Foundation

struct UserProfileUpdate: Sendable {
    let displayName: String
    let bio: String
}

protocol UserRepositoryProtocol: Sendable {
    func fetchCurrentUser() async throws -> User
    func updateProfile(_ update: UserProfileUpdate) async throws -> User
}
