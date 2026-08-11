import Foundation

actor GenreRepository: GenreRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let localeProvider: LocaleProviderProtocol
    private var cache: [Genre]?

    init(networkService: NetworkServiceProtocol, localeProvider: LocaleProviderProtocol) {
        self.networkService = networkService
        self.localeProvider = localeProvider
    }

    func invalidateCache() {
        cache = nil
    }

    func genres() async throws -> [Genre] {
        if let cache {
            return cache
        }

        let endpoint = GenreEndpoint.movieList(language: localeProvider.apiLanguage)
        let response: GenreListResponse = try await networkService.request(endpoint)
        let result = response.genres.map { $0.toDomain() }
        cache = result
        return result
    }
}
