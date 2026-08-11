import Foundation

actor GenreRepository: GenreRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private var cache: [Genre]?

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func invalidateCache() {
        cache = nil
    }

    func genres() async throws -> [Genre] {
        if let cache {
            return cache
        }

        let response: GenreListResponse = try await networkService.request(GenreEndpoint.movieList)
        let result = response.genres.map { $0.toDomain() }
        cache = result
        return result
    }
}
