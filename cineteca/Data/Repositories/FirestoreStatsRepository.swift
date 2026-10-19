import Foundation

final class FirestoreStatsRepository: StatsRepositoryProtocol, @unchecked Sendable {
    private let activityRepository: FirestoreMovieActivityRepository

    init(activityRepository: FirestoreMovieActivityRepository) {
        self.activityRepository = activityRepository
    }

    func fetchYearInFilmStats() async throws -> YearInFilmStats {
        let year = Calendar.current.component(.year, from: Date())
        let records = try await activityRepository.fetchActivityRecords()
        let ratedRecords = records.filter {
            guard let ratedAt = $0.ratedAt else { return false }
            return Calendar.current.component(.year, from: ratedAt) == year
        }
        let reviewsCount = records.filter { $0.review != nil }.count

        return YearInFilmStats(
            year: year,
            filmsCount: ratedRecords.count,
            hoursWatched: hoursWatched(for: ratedRecords),
            reviewsCount: reviewsCount,
            genres: genreStats(for: ratedRecords),
            topDirector: topPerson(names: ratedRecords.flatMap(\.metadata.directorNames)),
            topActor: topPerson(names: ratedRecords.flatMap(\.metadata.actorNames)),
            monthlyActivity: monthlyActivity(for: ratedRecords, year: year)
        )
    }

    private func hoursWatched(for records: [FirestoreActivityRecord]) -> Int {
        let minutes = records.reduce(0) {
            $0 + ($1.metadata.runtimeMinutes ?? 0)
        }
        return Int((Double(minutes) / 60.0).rounded())
    }

    private func genreStats(for records: [FirestoreActivityRecord]) -> [GenreStat] {
        guard !records.isEmpty else { return [] }

        var counts = Dictionary(uniqueKeysWithValues: GenreStatID.allCases.map { ($0, 0) })
        records.forEach { record in
            counts[primaryGenre(for: record.metadata.genres), default: 0] += 1
        }
        return counts
            .filter { $0.value > 0 }
            .sorted { $0.key.sortOrder < $1.key.sortOrder }
            .map {
                GenreStat(id: $0.key, percentage: Double($0.value) / Double(records.count))
            }
    }

    private func primaryGenre(for genres: [Genre]) -> GenreStatID {
        for genre in genres {
            switch genre.id {
            case 18: return .drama
            case 878: return .sciFi
            case 53: return .thriller
            case 35: return .comedy
            default: continue
            }
        }
        return .other
    }

    private func topPerson(names: [String]) -> PersonStat {
        let counts = names.reduce(into: [String: Int]()) { result, name in
            guard !name.isEmpty else { return }
            result[name, default: 0] += 1
        }
        let top = counts.max {
            if $0.value == $1.value { return $0.key > $1.key }
            return $0.value < $1.value
        }
        return PersonStat(name: top?.key ?? "", filmsWatched: top?.value ?? 0, profileURL: nil)
    }

    private func monthlyActivity(
        for records: [FirestoreActivityRecord],
        year: Int
    ) -> [MonthlyActivityStat] {
        let calendar = Calendar.current
        let counts = records.reduce(into: [Int: Int]()) { result, record in
            guard
                let ratedAt = record.ratedAt,
                calendar.component(.year, from: ratedAt) == year
            else { return }
            result[calendar.component(.month, from: ratedAt), default: 0] += 1
        }
        return (1...12).map {
            MonthlyActivityStat(monthIndex: $0, filmsCount: counts[$0, default: 0])
        }
    }
}

private extension GenreStatID {
    static var allCases: [GenreStatID] {
        [.drama, .sciFi, .thriller, .comedy, .other]
    }

    var sortOrder: Int {
        switch self {
        case .drama: 0
        case .sciFi: 1
        case .thriller: 2
        case .comedy: 3
        case .other: 4
        }
    }
}
