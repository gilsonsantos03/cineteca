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
                let header: HeaderViewModel
                let summary: SummaryViewModel
                let genres: GenreDistributionViewModel
                let topDirector: TopPersonViewModel
                let topActor: TopPersonViewModel
                let monthlyActivity: MonthlyActivityViewModel
            }
        }
    }

    struct HeaderViewModel {
        let yearText: String
        let title: String
    }

    struct SummaryViewModel {
        let filmsCount: String
        let hoursWatched: String
        let reviewsCount: String
    }

    struct GenreDistributionViewModel {
        let title: String
        let rows: [GenreRowViewModel]
    }

    struct GenreRowViewModel {
        let name: String
        let percentageText: String
        let progress: Double
        let tone: GenreTone
    }

    enum GenreTone {
        case accent
        case pink
        case cyan
        case muted
    }

    struct TopPersonViewModel {
        let sectionTitle: String
        let name: String
        let subtitle: String
        let profileURL: URL?
    }

    struct MonthlyActivityViewModel {
        let title: String
        let subtitle: String
        let bars: [MonthlyBarViewModel]
    }

    struct MonthlyBarViewModel {
        let monthLabel: String
        let valueText: String
        let relativeHeight: Double
    }
}
