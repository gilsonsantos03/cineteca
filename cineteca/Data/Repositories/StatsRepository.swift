import Foundation

final class StatsRepository: StatsRepositoryProtocol {
    func fetchYearInFilmStats() async throws -> YearInFilmStats {
        StatsSeedData.makeYearInFilmStats()
    }
}

enum StatsSeedData {
    static func makeYearInFilmStats() -> YearInFilmStats {
        let year = Calendar.current.component(.year, from: Date())

        return YearInFilmStats(
            year: year,
            filmsCount: 127,
            hoursWatched: 318,
            reviewsCount: 42,
            genres: [
                GenreStat(id: .drama, percentage: 0.38),
                GenreStat(id: .sciFi, percentage: 0.24),
                GenreStat(id: .thriller, percentage: 0.16),
                GenreStat(id: .comedy, percentage: 0.12),
                GenreStat(id: .other, percentage: 0.10)
            ],
            topDirector: PersonStat(
                name: "Denis Villeneuve",
                filmsWatched: 8,
                profileURL: profileURL(path: "/1Rr5SrvHxMXHu5RjKiuFpPHjklZ.jpg")
            ),
            topActor: PersonStat(
                name: "Timothée Chalamet",
                filmsWatched: 6,
                profileURL: profileURL(path: "/BE2Nud3VmcqG3PK1nNW7XGYpTl.jpg")
            ),
            monthlyActivity: [
                MonthlyActivityStat(monthIndex: 1, filmsCount: 8),
                MonthlyActivityStat(monthIndex: 2, filmsCount: 11),
                MonthlyActivityStat(monthIndex: 3, filmsCount: 9),
                MonthlyActivityStat(monthIndex: 4, filmsCount: 14),
                MonthlyActivityStat(monthIndex: 5, filmsCount: 10),
                MonthlyActivityStat(monthIndex: 6, filmsCount: 7),
                MonthlyActivityStat(monthIndex: 7, filmsCount: 12),
                MonthlyActivityStat(monthIndex: 8, filmsCount: 15),
                MonthlyActivityStat(monthIndex: 9, filmsCount: 13),
                MonthlyActivityStat(monthIndex: 10, filmsCount: 11),
                MonthlyActivityStat(monthIndex: 11, filmsCount: 9),
                MonthlyActivityStat(monthIndex: 12, filmsCount: 8)
            ]
        )
    }

    private static func profileURL(path: String) -> URL? {
        URL(string: TMDBImage.profileBaseURL + path)
    }
}
