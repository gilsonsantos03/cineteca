import CoreData
import Foundation

final class StatsRepository: StatsRepositoryProtocol, @unchecked Sendable {
    private let activityRepository: MovieActivityRepositoryProtocol
    private let coreDataStack: CoreDataStack

    init(
        activityRepository: MovieActivityRepositoryProtocol,
        coreDataStack: CoreDataStack
    ) {
        self.activityRepository = activityRepository
        self.coreDataStack = coreDataStack
    }

    func fetchYearInFilmStats() async throws -> YearInFilmStats {
        let year = Calendar.current.component(.year, from: Date())
        let activities = try await activityRepository.fetchActivities()
        let ratedActivities = activities.filter {
            guard let ratedAt = $0.ratedAt else { return false }
            return Calendar.current.component(.year, from: ratedAt) == year
        }
        let reviewsCount = try await fetchReviewCount()

        return YearInFilmStats(
            year: year,
            filmsCount: ratedActivities.count,
            hoursWatched: hoursWatched(for: ratedActivities),
            reviewsCount: reviewsCount,
            genres: genreStats(for: ratedActivities),
            topDirector: topPerson(names: ratedActivities.flatMap(\.metadata.directorNames)),
            topActor: topPerson(names: ratedActivities.flatMap(\.metadata.actorNames)),
            monthlyActivity: monthlyActivity(for: ratedActivities, year: year)
        )
    }

    private func fetchReviewCount() async throws -> Int {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request = ReviewEntity.fetchRequest()
            return try context.count(for: request)
        }
    }

    private func hoursWatched(for activities: [MovieActivity]) -> Int {
        let minutes = activities.reduce(0) {
            $0 + ($1.metadata.runtimeMinutes ?? 0)
        }
        return Int((Double(minutes) / 60.0).rounded())
    }

    private func genreStats(for activities: [MovieActivity]) -> [GenreStat] {
        guard !activities.isEmpty else { return [] }

        var counts = Dictionary(uniqueKeysWithValues: GenreStatID.allCases.map { ($0, 0) })
        activities.forEach { activity in
            counts[primaryGenre(for: activity.metadata.genres), default: 0] += 1
        }

        return counts
            .filter { $0.value > 0 }
            .sorted { $0.key.sortOrder < $1.key.sortOrder }
            .map {
                GenreStat(
                    id: $0.key,
                    percentage: Double($0.value) / Double(activities.count)
                )
            }
    }

    private func primaryGenre(for genres: [Genre]) -> GenreStatID {
        for genre in genres {
            switch genre.id {
            case 18:
                return .drama
            case 878:
                return .sciFi
            case 53:
                return .thriller
            case 35:
                return .comedy
            default:
                continue
            }
        }
        return .other
    }

    private func topPerson(names: [String]) -> PersonStat {
        let counts = names.reduce(into: [String: Int]()) { counts, name in
            guard !name.isEmpty else { return }
            counts[name, default: 0] += 1
        }
        let top = counts.max { first, second in
            if first.value == second.value {
                return first.key > second.key
            }
            return first.value < second.value
        }
        return PersonStat(
            name: top?.key ?? "",
            filmsWatched: top?.value ?? 0,
            profileURL: nil
        )
    }

    private func monthlyActivity(
        for activities: [MovieActivity],
        year: Int
    ) -> [MonthlyActivityStat] {
        let calendar = Calendar.current
        let counts = activities.reduce(into: [Int: Int]()) { counts, activity in
            guard let ratedAt = activity.ratedAt else { return }
            guard calendar.component(.year, from: ratedAt) == year else { return }
            let month = calendar.component(.month, from: ratedAt)
            counts[month, default: 0] += 1
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
