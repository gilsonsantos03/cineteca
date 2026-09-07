import Foundation

protocol UserRepositoryProtocol: Sendable {
    func fetchCurrentUser() async throws -> User
}
