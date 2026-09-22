import Foundation

enum StatsModels {
    enum FetchStats {
        struct Request {}

        enum Response {
            case content(YearInFilmStats)
            case error
        }

        enum ViewModel {
            case content(Content)
            case error

            struct Content {
                let header: StatsHeaderViewModel
                let summary: ProfileStatsViewModel
                let genres: StatsGenreDistributionViewModel
                let topDirector: StatsTopPersonViewModel
                let topActor: StatsTopPersonViewModel
                let monthlyActivity: StatsMonthlyActivityViewModel
            }
        }
    }
}

struct StatsHeaderViewModel {
    let yearText: String
    let title: String
}

struct StatsGenreDistributionViewModel {
    let title: String
    let rows: [StatsGenreRowViewModel]
}

struct StatsGenreRowViewModel {
    let name: String
    let percentageText: String
    let progress: Double
    let tone: GenreStatTone
}

enum GenreStatTone {
    case accent
    case pink
    case cyan
    case muted
}

struct StatsTopPersonViewModel {
    let sectionTitle: String
    let name: String
    let subtitle: String
    let profileURL: URL?
}

struct StatsMonthlyActivityViewModel {
    let title: String
    let subtitle: String
    let bars: [StatsMonthlyBarViewModel]
}

struct StatsMonthlyBarViewModel {
    let monthLabel: String
    let valueText: String
    let relativeHeight: Double
}
