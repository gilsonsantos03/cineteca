import Foundation

protocol StatsRepositoryProtocol: Sendable {
    func cachedFilmStatsHistory() -> FilmStatsHistory?
    func fetchFilmStatsHistory() async throws -> FilmStatsHistory
}
