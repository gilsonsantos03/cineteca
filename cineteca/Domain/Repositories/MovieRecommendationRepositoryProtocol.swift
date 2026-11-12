import Foundation

protocol MovieRecommendationRepositoryProtocol: Sendable {
    func recommend(mode: MovieRecommendationMode) async throws -> MovieRecommendation
}
