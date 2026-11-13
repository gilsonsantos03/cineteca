import Foundation

enum StatsModels {
    enum Period: Equatable {
        case allTime
        case year(Int)
    }

    enum FetchStats {
        struct Request {}

        enum Response {
            case content(history: FilmStatsHistory, periods: [Period], selectedPeriod: Period)
            case error
        }

        enum ViewModel {
            case content(Content)
            case error

            struct Content {
                let header: HeaderViewModel
                let periodFilter: PeriodFilterViewModel
                let summary: SummaryViewModel
                let genres: GenreDistributionViewModel
                let topDirector: TopPersonViewModel
                let topActor: TopPersonViewModel
                let activity: ActivityViewModel
            }
        }
    }

    enum SelectPeriod {
        struct Request {
            let index: Int
        }
    }

    struct HeaderViewModel {
        let periodText: String
        let title: String
    }

    struct PeriodFilterViewModel {
        let options: [String]
        let selectedIndex: Int
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

    struct ActivityViewModel {
        let title: String
        let subtitle: String
        let bars: [ActivityBarViewModel]
    }

    struct ActivityBarViewModel {
        let label: String
        let valueText: String
        let relativeHeight: Double
    }
}
