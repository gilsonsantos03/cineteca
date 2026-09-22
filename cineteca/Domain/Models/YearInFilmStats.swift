import Foundation

struct YearInFilmStats: Sendable {
    let year: Int
    let filmsCount: Int
    let hoursWatched: Int
    let reviewsCount: Int
    let genres: [GenreStat]
    let topDirector: PersonStat
    let topActor: PersonStat
    let monthlyActivity: [MonthlyActivityStat]
}

struct GenreStat: Sendable {
    let id: GenreStatID
    let percentage: Double
}

enum GenreStatID: String, Sendable {
    case drama
    case sciFi
    case thriller
    case comedy
    case other
}

struct PersonStat: Sendable {
    let name: String
    let filmsWatched: Int
    let profileURL: URL?
}

struct MonthlyActivityStat: Sendable {
    let monthIndex: Int
    let filmsCount: Int
}
