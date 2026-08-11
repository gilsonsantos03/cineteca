import Foundation

struct GenreResponse: Decodable, Sendable {
    let id: Int
    let name: String
}

struct GenreListResponse: Decodable, Sendable {
    let genres: [GenreResponse]
}

extension GenreResponse {
    func toDomain() -> Genre {
        Genre(id: id, name: name)
    }
}
