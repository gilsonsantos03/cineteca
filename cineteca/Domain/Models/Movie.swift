import Foundation

struct Movie: Sendable {
    let id: Int
    let title: String
    let posterURL: URL?
    let backdropURL: URL?
    let releaseYear: String
    let rating: Double
    let genres: [Genre]
    let runtime: Int?
}
