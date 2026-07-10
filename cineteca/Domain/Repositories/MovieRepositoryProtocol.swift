import Foundation

protocol MovieRepositoryProtocol {
    func fetchNowPlaying() async throws -> [Movie]
    func fetchTrending() async throws -> [Movie]
    func fetchTopRated() async throws -> [Movie]
    func fetchFeatured() async throws -> [Movie]
}
