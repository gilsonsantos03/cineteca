import Foundation

struct GenreDTO: Decodable, Sendable {
    let id: Int
    let name: String
}

struct GenreListResponseDTO: Decodable, Sendable {
    let genres: [GenreDTO]
}
