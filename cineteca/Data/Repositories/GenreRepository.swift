import Foundation

actor GenreRepository: GenreRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let localeProvider: LocaleProviderProtocol
    private var cache: [Int: String]?

    init(networkService: NetworkServiceProtocol, localeProvider: LocaleProviderProtocol) {
        self.networkService = networkService
        self.localeProvider = localeProvider
    }

    func invalidateCache() {
        cache = nil
    }

    func genres() async throws -> [Int: String] {
        if let cache {
            return cache
        }

        let endpoint = GenreEndpoint.movieList(language: localeProvider.apiLanguage)
        let response: GenreListResponseDTO = try await networkService.request(endpoint)
        let result = Dictionary(uniqueKeysWithValues: response.genres.map { ($0.id, $0.name) })
        cache = result
        return result
    }
}
