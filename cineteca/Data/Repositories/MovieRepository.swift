import Foundation

final class MovieRepository: MovieRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let genreRepository: GenreRepositoryProtocol
    private let localeProvider: LocaleProviderProtocol

    init(
        networkService: NetworkServiceProtocol,
        genreRepository: GenreRepositoryProtocol,
        localeProvider: LocaleProviderProtocol
    ) {
        self.networkService = networkService
        self.genreRepository = genreRepository
        self.localeProvider = localeProvider
    }

    func fetchNowPlaying() async throws -> [Movie] {
        try await fetchMovies(from: .nowPlaying(language: localeProvider.apiLanguage))
    }

    func fetchTrending() async throws -> [Movie] {
        try await fetchMovies(from: .trending(language: localeProvider.apiLanguage))
    }

    func fetchTopRated() async throws -> [Movie] {
        try await fetchMovies(from: .topRated(language: localeProvider.apiLanguage))
    }

    func fetchFeatured() async throws -> [Movie] {
        try await fetchMovies(from: .featured(language: localeProvider.apiLanguage))
    }

    private func fetchMovies(from endpoint: MovieEndpoint) async throws -> [Movie] {
        async let responseTask: MovieResponseDTO = networkService.request(endpoint)
        async let genreMapTask = genreRepository.genres()
        let (response, genreMap) = try await (responseTask, genreMapTask)
        return response.results.map { $0.asDomain(genreMap: genreMap) }
    }
}
