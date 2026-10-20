import Foundation

struct MovieDetails: Sendable {
    let id: Int
    let title: String
    let overview: String
    let posterURL: URL?
    let backdropURL: URL?
    let releaseYear: String
    let runtime: Int?
    let certification: String?
    let rating: Double
    let genres: [Genre]
    let cast: [MovieCastMember]
    let crew: [MovieCrewMember]
    let watchProviders: MovieWatchProviders
    let similarMovies: [Movie]
}

struct MovieCastMember: Sendable {
    let id: Int
    let name: String
    let character: String
    let profileURL: URL?
}

struct MovieCrewMember: Sendable {
    let id: Int
    let name: String
    let job: String
}

struct MovieWatchProviders: Sendable {
    let groups: [MovieWatchProviderGroup]
    let optionsURL: URL?
}

struct MovieWatchProviderGroup: Sendable {
    let category: WatchProviderCategory
    let providers: [WatchProvider]
}

enum WatchProviderCategory: Sendable, Equatable {
    case streaming
    case rent
    case buy
    case free
    case withAds
}

struct WatchProvider: Sendable {
    let name: String
    let logoURL: URL?
}
