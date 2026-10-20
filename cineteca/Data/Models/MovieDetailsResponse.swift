import Foundation

struct MovieDetailsResponse: Decodable, Sendable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let runtime: Int?
    let genres: [GenreResponse]
}

struct CreditsResponse: Decodable, Sendable {
    let cast: [CastMemberResponse]
    let crew: [CrewMemberResponse]
}

struct CastMemberResponse: Decodable, Sendable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let order: Int
}

struct CrewMemberResponse: Decodable, Sendable {
    let id: Int
    let name: String
    let job: String
}

struct WatchProvidersResponse: Decodable, Sendable {
    let results: [String: WatchProvidersCountryResponse]
}

struct WatchProvidersCountryResponse: Decodable, Sendable {
    let link: String?
    let flatrate: [WatchProviderResponse]?
    let rent: [WatchProviderResponse]?
    let buy: [WatchProviderResponse]?
    let free: [WatchProviderResponse]?
    let ads: [WatchProviderResponse]?

    func toDomain() -> MovieWatchProviders {
        var groups: [MovieWatchProviderGroup] = []
        appendGroup(.streaming, providers: flatrate, to: &groups)
        appendGroup(.rent, providers: rent, to: &groups)
        appendGroup(.buy, providers: buy, to: &groups)
        appendGroup(.free, providers: free, to: &groups)
        appendGroup(.withAds, providers: ads, to: &groups)

        return MovieWatchProviders(
            groups: groups,
            optionsURL: link.flatMap { URL(string: $0) }
        )
    }

    private func appendGroup(
        _ category: WatchProviderCategory,
        providers: [WatchProviderResponse]?,
        to groups: inout [MovieWatchProviderGroup]
    ) {
        guard let providers, !providers.isEmpty else { return }
        groups.append(
            MovieWatchProviderGroup(
                category: category,
                providers: providers.map { $0.toDomain() }
            )
        )
    }
}

struct WatchProviderResponse: Decodable, Sendable {
    let providerName: String
    let logoPath: String?
}

struct ReleaseDatesResponse: Decodable, Sendable {
    let results: [ReleaseDatesCountryResponse]
}

struct ReleaseDatesCountryResponse: Decodable, Sendable {
    let iso31661: String
    let releaseDates: [ReleaseDateResponse]
}

struct ReleaseDateResponse: Decodable, Sendable {
    let certification: String
}

extension MovieDetailsResponse {
    func toDomain(
        certification: String?,
        cast: [MovieCastMember],
        crew: [MovieCrewMember],
        watchProviders: MovieWatchProviders,
        similarMovies: [Movie]
    ) -> MovieDetails {
        MovieDetails(
            id: id,
            title: title,
            overview: overview,
            posterURL: posterPath.flatMap { URL(string: TMDBImage.posterBaseURL + $0) },
            backdropURL: backdropPath.flatMap { URL(string: TMDBImage.backdropBaseURL + $0) },
            releaseYear: releaseDate?.prefix(4).description ?? "",
            runtime: runtime,
            certification: certification,
            rating: voteAverage,
            genres: genres.map { $0.toDomain() },
            cast: cast,
            crew: crew,
            watchProviders: watchProviders,
            similarMovies: similarMovies
        )
    }
}

extension CastMemberResponse {
    func toDomain() -> MovieCastMember {
        MovieCastMember(
            id: id,
            name: name,
            character: character,
            profileURL: profilePath.flatMap { URL(string: TMDBImage.profileBaseURL + $0) }
        )
    }
}

extension CrewMemberResponse {
    func toDomain() -> MovieCrewMember {
        MovieCrewMember(id: id, name: name, job: job)
    }
}

extension WatchProviderResponse {
    func toDomain() -> WatchProvider {
        WatchProvider(
            name: providerName,
            logoURL: logoPath.flatMap { URL(string: TMDBImage.providerLogoBaseURL + $0) }
        )
    }
}
