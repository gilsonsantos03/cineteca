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

    func fetchMovieDetails(for movieId: Int) async throws -> MovieDetails {
        let language = localeProvider.apiLanguage
        async let creditsTask: CreditsResponseDTO? = try? networkService.request(
            MovieEndpoint.credits(movieId: movieId, language: language)
        )
        async let providersTask: WatchProvidersResponseDTO? = try? networkService.request(
            MovieEndpoint.watchProviders(movieId: movieId)
        )
        async let releaseDatesTask: ReleaseDatesResponseDTO? = try? networkService.request(
            MovieEndpoint.releaseDates(movieId: movieId)
        )
        async let similarTask: MovieResponseDTO? = try? networkService.request(
            MovieEndpoint.similar(movieId: movieId, language: language)
        )

        let detailsResponse: MovieDetailsDTO = try await networkService.request(
            MovieEndpoint.details(movieId: movieId, language: language)
        )
        let (credits, providers, releaseDates, similar) = await (
            creditsTask,
            providersTask,
            releaseDatesTask,
            similarTask
        )

        return detailsResponse.asDomain(
            certification: certification(from: releaseDates, for: regionCode),
            cast: (credits?.cast ?? []).sorted { $0.order < $1.order }.prefix(10).map { $0.asDomain() },
            crew: (credits?.crew ?? [])
                .filter { $0.job == "Director" || $0.job == "Writer" || $0.job == "Screenplay" }
                .map { $0.asDomain() },
            watchProviders: providers?.results[regionCode]?.allProviders.map { $0.asDomain() } ?? [],
            similarMovies: (similar?.results ?? []).map { $0.asDomain(genreMap: [:]) }
        )
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

    private var regionCode: String {
        localeProvider.apiLanguage.split(separator: "-").last.map(String.init) ?? "US"
    }

    private func certification(
        from response: ReleaseDatesResponseDTO?,
        for regionCode: String
    ) -> String? {
        let matchingCountry = response?.results.first { $0.iso31661 == regionCode }
            ?? response?.results.first { $0.iso31661 == "US" }
        return matchingCountry?.releaseDates.first { !$0.certification.isEmpty }?.certification
    }
}
