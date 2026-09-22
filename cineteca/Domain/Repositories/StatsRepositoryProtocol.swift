import Foundation

protocol StatsRepositoryProtocol: Sendable {
    func fetchYearInFilmStats() async throws -> YearInFilmStats
}
