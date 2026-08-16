import Foundation

protocol MovieRepositoryProtocol {
    func fetchNowPlaying(genres: [Genre]) async throws -> [Movie]
    func fetchTrending(genres: [Genre]) async throws -> [Movie]
    func fetchTopRated(genres: [Genre]) async throws -> [Movie]
    func fetchFeatured(genres: [Genre]) async throws -> [Movie]
    func searchMovies(query: String, genres: [Genre]) async throws -> [Movie]
    func discoverMovies(filters: SearchFilters, query: String?, genres: [Genre]) async throws -> [Movie]
    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetails
    func fetchTrailerKey(for movieId: Int) async throws -> String?
}
