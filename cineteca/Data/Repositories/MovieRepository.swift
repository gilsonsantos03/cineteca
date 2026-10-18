import Foundation

final class MovieRepository: MovieRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchNowPlaying(genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .nowPlaying(page: 1), genres: genres)
    }

    func fetchTrending(genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .trending(page: 1), genres: genres)
    }

    func fetchTopRated(genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .topRated(page: 1), genres: genres)
    }

    func fetchFeatured(genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .featured(page: 1), genres: genres)
    }

    func fetchMovieCollection(
        category: MovieCollectionCategory,
        page: Int,
        genres: [Genre]
    ) async throws -> MovieCollectionPage {
        let endpoint: MovieEndpoint

        switch category {
        case .nowPlaying:
            endpoint = .nowPlaying(page: page)
        case .trending:
            endpoint = .trending(page: page)
        case .topRated:
            endpoint = .topRated(page: page)
        }

        return try await fetchMoviePage(from: endpoint, page: page, genres: genres)
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
        try await fetchMoviePage(from: endpoint, page: 1, genres: genres).movies
    }

    private func fetchMoviePage(
        from endpoint: MovieEndpoint,
        page: Int,
        genres: [Genre]
    ) async throws -> MovieCollectionPage {
        let genreLookup = genres.lookupById
        let response: MovieListResponse = try await networkService.request(endpoint)
        return MovieCollectionPage(
            movies: response.results.map { $0.toDomain(genreLookup: genreLookup) },
            page: response.page ?? page,
            totalPages: response.totalPages ?? page
        )
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
