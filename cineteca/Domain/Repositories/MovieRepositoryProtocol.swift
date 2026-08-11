import Foundation

protocol MovieRepositoryProtocol {
    func fetchNowPlaying(genreMap: [Int: String]) async throws -> [Movie]
    func fetchTrending(genreMap: [Int: String]) async throws -> [Movie]
    func fetchTopRated(genreMap: [Int: String]) async throws -> [Movie]
    func fetchFeatured(genreMap: [Int: String]) async throws -> [Movie]
    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetails
    func fetchTrailerKey(for movieId: Int) async throws -> String?
}
