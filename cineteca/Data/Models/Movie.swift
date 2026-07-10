import Foundation

struct Movie: Sendable {
    let id: Int
    let title: String
    let posterURL: URL?
    let backdropURL: URL?
    let releaseYear: String
    let rating: Double
    let genres: [String]
    let runtime: Int?
}
