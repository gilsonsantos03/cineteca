import Foundation

protocol GenreRepositoryProtocol: Sendable {
    func genres() async throws -> [Int: String]
    func invalidateCache() async
}
