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

    func fetchNowPlaying(genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .nowPlaying(language: localeProvider.apiLanguage), genres: genres)
    }

    func fetchTrending(genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .trending(language: localeProvider.apiLanguage), genres: genres)
    }

    func fetchTopRated(genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .topRated(language: localeProvider.apiLanguage), genres: genres)
    }

    func fetchFeatured(genres: [Genre]) async throws -> [Movie] {
        try await fetchMovies(from: .featured(language: localeProvider.apiLanguage), genres: genres)
    }

    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetails {
        let language = localeProvider.apiLanguage
        async let creditsTask: CreditsResponse? = try? networkService.request(
            MovieEndpoint.credits(movieId: movieId, language: language)
        )
        async let providersTask: WatchProvidersResponse? = try? networkService.request(
            MovieEndpoint.watchProviders(movieId: movieId)
        )
        async let releaseDatesTask: ReleaseDatesResponse? = try? networkService.request(
            MovieEndpoint.releaseDates(movieId: movieId)
        )
        async let similarTask: MovieListResponse? = try? networkService.request(
            MovieEndpoint.similar(movieId: movieId, language: language)
        )

        let detailsResponse: MovieDetailsResponse = try await networkService.request(
            MovieEndpoint.details(movieId: movieId, language: language)
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
        let endpoint = MovieEndpoint.videos(movieId: movieId, language: localeProvider.apiLanguage)
        let response: VideoListResponse = try await networkService.request(endpoint)
        return response.youtubeTrailerKey()
    }

    private func fetchMovies(from endpoint: MovieEndpoint, genres: [Genre]) async throws -> [Movie] {
        let genreLookup = genres.lookupById
        let response: MovieListResponse = try await networkService.request(endpoint)
        return response.results.map { $0.toDomain(genreLookup: genreLookup) }
    }

    private var regionCode: String {
        localeProvider.apiLanguage.split(separator: "-").last.map(String.init) ?? "US"
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
