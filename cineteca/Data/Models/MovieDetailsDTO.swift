import Foundation

struct MovieDetailsDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let runtime: Int?
    let genres: [GenreDTO]
}

struct CreditsResponseDTO: Decodable, Sendable {
    let cast: [CastMemberDTO]
    let crew: [CrewMemberDTO]
}

struct CastMemberDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let order: Int
}

struct CrewMemberDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let job: String
}

struct WatchProvidersResponseDTO: Decodable, Sendable {
    let results: [String: WatchProvidersCountryDTO]
}

struct WatchProvidersCountryDTO: Decodable, Sendable {
    let flatrate: [WatchProviderDTO]?
    let rent: [WatchProviderDTO]?
    let buy: [WatchProviderDTO]?

    var allProviders: [WatchProviderDTO] {
        let combined = (flatrate ?? []) + (rent ?? []) + (buy ?? [])
        var seenProviderIDs = Set<Int>()
        return combined.filter { seenProviderIDs.insert($0.providerID).inserted }
    }
}

struct WatchProviderDTO: Decodable, Sendable {
    let providerID: Int
    let providerName: String
    let logoPath: String?
}

struct ReleaseDatesResponseDTO: Decodable, Sendable {
    let results: [ReleaseDatesCountryDTO]
}

struct ReleaseDatesCountryDTO: Decodable, Sendable {
    let iso31661: String
    let releaseDates: [ReleaseDateDTO]
}

struct ReleaseDateDTO: Decodable, Sendable {
    let certification: String
}

extension MovieDetailsDTO {
    func asDomain(
        certification: String?,
        cast: [MovieCastMember],
        crew: [MovieCrewMember],
        watchProviders: [WatchProvider],
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
            genres: genres.map(\.name),
            cast: cast,
            crew: crew,
            watchProviders: watchProviders,
            similarMovies: similarMovies
        )
    }
}

extension CastMemberDTO {
    func asDomain() -> MovieCastMember {
        MovieCastMember(
            id: id,
            name: name,
            character: character,
            profileURL: profilePath.flatMap { URL(string: TMDBImage.profileBaseURL + $0) }
        )
    }
}

extension CrewMemberDTO {
    func asDomain() -> MovieCrewMember {
        MovieCrewMember(id: id, name: name, job: job)
    }
}

extension WatchProviderDTO {
    func asDomain() -> WatchProvider {
        WatchProvider(
            name: providerName,
            logoURL: logoPath.flatMap { URL(string: TMDBImage.providerLogoBaseURL + $0) }
        )
    }
}
