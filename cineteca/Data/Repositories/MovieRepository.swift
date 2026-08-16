import Foundation

final class MovieRepository: MovieRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchNowPlaying(genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .nowPlaying, genres: genres)
    }

    func fetchTrending(genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .trending, genres: genres)
    }

    func fetchTopRated(genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .topRated, genres: genres)
    }

    func fetchFeatured(genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .featured, genres: genres)
    }

    func searchMovies(query: String, genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .search(query: query), genres: genres)
    }

    func discoverMovies(filters: SearchFilters, query: String?, genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .discover(filters: filters, query: query), genres: genres)
    }

    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetails {
        async let creditsTask: CreditsResponse? = try? networkService.request(
            MovieEndpoint.credits(movieId: movieId)
        )
        async let providersTask: WatchProvidersResponse? = try? networkService.request(
            MovieEndpoint.watchProviders(movieId: movieId)
        )
        async let releaseDatesTask: ReleaseDatesResponse? = try? networkService.request(
            MovieEndpoint.releaseDates(movieId: movieId)
        )
        async let similarTask: MovieListResponse? = try? networkService.request(
            MovieEndpoint.similar(movieId: movieId)
        )

        let detailsResponse: MovieDetailsResponse = try await networkService.request(
            MovieEndpoint.details(movieId: movieId)
        )
        let (credits, providers, releaseDates, similar) = await (
            creditsTask,
            providersTask,
            releaseDatesTask,
            similarTask
        )

        return detailsResponse.toDomain(
            certification: certification(from: releaseDates, for: regionCode),
            cast: (credits?.cast ?? []).sorted { $0.order < $1.order }.prefix(10).map { $0.toDomain() },
            crew: (credits?.crew ?? [])
                .filter { $0.job == "Director" || $0.job == "Writer" || $0.job == "Screenplay" }
                .map { $0.toDomain() },
            watchProviders: providers?.results[regionCode]?.allProviders.map { $0.toDomain() } ?? [],
            similarMovies: (similar?.results ?? []).map { $0.toDomain(genreLookup: [:]) }
        )
    }

    func fetchTrailerKey(for movieId: Int) async throws -> String? {
        let response: VideoListResponse = try await networkService.request(
            MovieEndpoint.videos(movieId: movieId)
        )
        return response.youtubeTrailerKey()
    }

    private func fetchMovies(from endpoint: MovieEndpoint, genres: [Genre]) async throws -> [Movie] {
        let genreLookup = genres.lookupById
        let response: MovieListResponse = try await networkService.request(endpoint)
        return response.results.map { $0.toDomain(genreLookup: genreLookup) }
    }

    private var regionCode: String {
        Locale.current.region?.identifier ?? "US"
    }

    private func certification(
        from response: ReleaseDatesResponse?,
        for regionCode: String
    ) -> String? {
        let matchingCountry = response?.results.first { $0.iso31661 == regionCode }
            ?? response?.results.first { $0.iso31661 == "US" }
        return matchingCountry?.releaseDates.first { !$0.certification.isEmpty }?.certification
    }
}
