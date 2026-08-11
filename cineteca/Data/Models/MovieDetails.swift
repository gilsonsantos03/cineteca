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
    let genres: [String]
    let cast: [MovieCastMember]
    let crew: [MovieCrewMember]
    let watchProviders: [WatchProvider]
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

struct WatchProvider: Sendable {
    let name: String
    let logoURL: URL?
}
