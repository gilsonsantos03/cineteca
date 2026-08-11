import Foundation

struct MovieResponse: Decodable, Sendable {
    let id: Int
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let genreIds: [Int]
    let runtime: Int?
}

struct MovieListResponse: Decodable, Sendable {
    let results: [MovieResponse]
}

struct VideoResponse: Decodable, Sendable {
    let key: String
    let site: String
    let type: String
    let official: Bool?
    let publishedAt: String?
}

struct VideoListResponse: Decodable, Sendable {
    let results: [VideoResponse]
}

extension VideoListResponse {
    func youtubeTrailerKey() -> String? {
        let trailers = results.filter { $0.site == "YouTube" && $0.type == "Trailer" }
        let selected = trailers.first(where: { $0.official == true }) ?? trailers.first
        return selected?.key
    }
}

enum TMDBImage {
    static let posterBaseURL = "https://image.tmdb.org/t/p/w500"
    static let backdropBaseURL = "https://image.tmdb.org/t/p/w780"
    static let profileBaseURL = "https://image.tmdb.org/t/p/w185"
    static let providerLogoBaseURL = "https://image.tmdb.org/t/p/w45"
}

extension MovieResponse {
    func toDomain(genreLookup: [Int: Genre]) -> Movie {
        Movie(
            id: id,
            title: title,
            posterURL: posterPath.flatMap { URL(string: TMDBImage.posterBaseURL + $0) },
            backdropURL: backdropPath.flatMap { URL(string: TMDBImage.backdropBaseURL + $0) },
            releaseYear: releaseDate?.prefix(4).description ?? "",
            rating: voteAverage,
            genres: genreIds.compactMap { genreLookup[$0] },
            runtime: runtime
        )
    }
}
