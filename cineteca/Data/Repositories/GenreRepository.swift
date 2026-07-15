import Foundation

actor GenreRepository: GenreRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let localeProvider: LocaleProviderProtocol
    private var cache: [Int: String]?
    private var inFlight: Task<[Int: String], Error>?

    init(networkService: NetworkServiceProtocol, localeProvider: LocaleProviderProtocol) {
        self.networkService = networkService
        self.localeProvider = localeProvider
    }

    func invalidateCache() {
        cache = nil
        inFlight?.cancel()
        inFlight = nil
    }

    func genres() async throws -> [Int: String] {
        if let cache {
            return cache
        }
        if let inFlight {
            return try await inFlight.value
        }

        let task = Task { [networkService, localeProvider] in
            let endpoint = GenreEndpoint.movieList(language: localeProvider.apiLanguage)
            let response: GenreListResponseDTO = try await networkService.request(endpoint)
            return Dictionary(uniqueKeysWithValues: response.genres.map { ($0.id, $0.name) })
        }
        inFlight = task

        do {
            let result = try await task.value
            cache = result
            inFlight = nil
            return result
        } catch {
            inFlight = nil
            throw error
        }
    }
}
