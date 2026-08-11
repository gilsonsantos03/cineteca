import Foundation

protocol GenreRepositoryProtocol: Sendable {
    func genres() async throws -> [Genre]
    func invalidateCache() async
}
