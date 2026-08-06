import Foundation

final class MovieRepository: MovieRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let localeProvider: LocaleProviderProtocol

    init(
        networkService: NetworkServiceProtocol,
        localeProvider: LocaleProviderProtocol
    ) {
        self.networkService = networkService
        self.localeProvider = localeProvider
    }

    func fetchNowPlaying(genreMap: [Int: String]) async throws -> [Movie] {
        try await fetchMovies(from: .nowPlaying(language: localeProvider.apiLanguage), genreMap: genreMap)
    }

    func fetchTrending(genreMap: [Int: String]) async throws -> [Movie] {
        try await fetchMovies(from: .trending(language: localeProvider.apiLanguage), genreMap: genreMap)
    }

    func fetchTopRated(genreMap: [Int: String]) async throws -> [Movie] {
        try await fetchMovies(from: .topRated(language: localeProvider.apiLanguage), genreMap: genreMap)
    }

    func fetchFeatured(genreMap: [Int: String]) async throws -> [Movie] {
        try await fetchMovies(from: .featured(language: localeProvider.apiLanguage), genreMap: genreMap)
    }

    func fetchTrailerKey(for movieId: Int) async throws -> String? {
        let endpoint = MovieEndpoint.videos(movieId: movieId, language: localeProvider.apiLanguage)
        let response: VideoListResponseDTO = try await networkService.request(endpoint)
        return response.youtubeTrailerKey()
    }

    private func fetchMovies(from endpoint: MovieEndpoint, genreMap: [Int: String]) async throws -> [Movie] {
        let response: MovieResponseDTO = try await networkService.request(endpoint)
        return response.results.map { $0.asDomain(genreMap: genreMap) }
    }
}
