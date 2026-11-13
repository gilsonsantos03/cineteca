import FirebaseAuth
import Foundation

final class FirestoreStatsRepository: StatsRepositoryProtocol, @unchecked Sendable {
    private let activityRepository: FirestoreMovieActivityRepository
    private let cache = UserScopedCache<FilmStatsHistory>()

    init(activityRepository: FirestoreMovieActivityRepository) {
        self.activityRepository = activityRepository
    }

    func cachedFilmStatsHistory() -> FilmStatsHistory? {
        guard
            let userID = Auth.auth().currentUser?.uid,
            let history = cache.value(for: userID),
            history.currentYear == Self.currentYear
        else { return nil }
        return history
    }

    func fetchFilmStatsHistory() async throws -> FilmStatsHistory {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw AuthenticationError.userNotAuthenticated
        }

        let records = try await activityRepository.fetchActivityRecords()
        let history = makeHistory(from: records)

        guard Auth.auth().currentUser?.uid == userID else {
            throw AuthenticationError.userNotAuthenticated
        }
        cache.store(history, for: userID)
        return history
    }

    private static var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private func makeHistory(from records: [FirestoreActivityRecord]) -> FilmStatsHistory {
        let calendar = Calendar.current
        let currentYear = Self.currentYear
        let ratedRecordsByYear = records.reduce(into: [Int: [FirestoreActivityRecord]]()) { result, record in
            guard let ratedAt = record.ratedAt else { return }
            result[calendar.component(.year, from: ratedAt), default: []].append(record)
        }
        let years = Set(ratedRecordsByYear.keys).union([currentYear]).sorted(by: >)

        let statsByYear = Dictionary(uniqueKeysWithValues: years.map { year in
            let yearRecords = ratedRecordsByYear[year] ?? []
            return (
                year,
                stats(
                    for: yearRecords,
                    reviewsCount: yearRecords.filter { $0.review != nil }.count,
                    activity: .monthly(monthlyActivity(for: yearRecords))
                )
            )
        })

        let allRatedRecords = ratedRecordsByYear.values.flatMap { $0 }
        let allTime = stats(
            for: allRatedRecords,
            reviewsCount: records.filter { $0.review != nil }.count,
            activity: .yearly(((years.last ?? currentYear)...currentYear).map {
                YearlyActivityStat(year: $0, filmsCount: ratedRecordsByYear[$0]?.count ?? 0)
            })
        )

        return FilmStatsHistory(
            currentYear: currentYear,
            years: years,
            allTime: allTime,
            statsByYear: statsByYear
        )
    }

    private func stats(
        for records: [FirestoreActivityRecord],
        reviewsCount: Int,
        activity: FilmActivity
    ) -> FilmStats {
        FilmStats(
            filmsCount: records.count,
            hoursWatched: hoursWatched(for: records),
            reviewsCount: reviewsCount,
            genres: genreStats(for: records),
            topDirector: topPerson(names: records.flatMap(\.metadata.directorNames)),
            topActor: topPerson(names: records.flatMap(\.metadata.actorNames)),
            activity: activity
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

    private func monthlyActivity(for records: [FirestoreActivityRecord]) -> [MonthlyActivityStat] {
        let calendar = Calendar.current
        let counts = records.reduce(into: [Int: Int]()) { result, record in
            guard let ratedAt = record.ratedAt else { return }
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
