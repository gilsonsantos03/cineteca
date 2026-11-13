import Foundation

struct FilmStatsHistory: Sendable {
    let currentYear: Int
    let years: [Int]
    let allTime: FilmStats
    let statsByYear: [Int: FilmStats]
}

struct FilmStats: Sendable {
    let filmsCount: Int
    let hoursWatched: Int
    let reviewsCount: Int
    let genres: [GenreStat]
    let topDirector: PersonStat
    let topActor: PersonStat
    let activity: FilmActivity
}

enum FilmActivity: Sendable {
    case monthly([MonthlyActivityStat])
    case yearly([YearlyActivityStat])
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

struct YearlyActivityStat: Sendable {
    let year: Int
    let filmsCount: Int
}
