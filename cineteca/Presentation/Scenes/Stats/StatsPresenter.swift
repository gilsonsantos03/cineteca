import Foundation

protocol StatsPresentationLogic {
    func presentFetchStats(response: StatsModels.FetchStats.Response)
    func presentLoading()
}

final class StatsPresenter {
    weak var view: StatsDisplayLogic?

    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM"
        return formatter
    }()
}

extension StatsPresenter: StatsPresentationLogic {
    func presentFetchStats(response: StatsModels.FetchStats.Response) {
        switch response {
        case .content(let stats):
            view?.displayFetchStats(viewModel: .content(makeContent(from: stats)))
        case .error:
            view?.displayFetchStats(viewModel: .error)
        }
    }

    func presentLoading() {
        view?.displayLoading()
    }

    private func makeContent(from stats: YearInFilmStats) -> StatsModels.FetchStats.ViewModel.Content {
        let maxMonthly = stats.monthlyActivity.map(\.filmsCount).max() ?? 1

        return StatsModels.FetchStats.ViewModel.Content(
            header: StatsModels.HeaderViewModel(
                yearText: "\(stats.year)",
                title: Strings.StatsScene.title
            ),
            summary: StatsModels.SummaryViewModel(
                filmsCount: "\(stats.filmsCount)",
                hoursWatched: "\(stats.hoursWatched)",
                reviewsCount: "\(stats.reviewsCount)"
            ),
            genres: StatsModels.GenreDistributionViewModel(
                title: Strings.StatsScene.GenreDistribution.title,
                rows: stats.genres.map { genre in
                    StatsModels.GenreRowViewModel(
                        name: genreName(for: genre.id),
                        percentageText: "\(Int((genre.percentage * 100).rounded()))%",
                        progress: genre.percentage,
                        tone: genreTone(for: genre.id)
                    )
                }
            ),
            topDirector: StatsModels.TopPersonViewModel(
                sectionTitle: Strings.StatsScene.TopDirector.title,
                name: stats.topDirector.name,
                subtitle: String(
                    format: Strings.StatsScene.filmsWatchedFormat,
                    stats.topDirector.filmsWatched
                ),
                profileURL: stats.topDirector.profileURL
            ),
            topActor: StatsModels.TopPersonViewModel(
                sectionTitle: Strings.StatsScene.TopActor.title,
                name: stats.topActor.name,
                subtitle: String(
                    format: Strings.StatsScene.filmsWatchedFormat,
                    stats.topActor.filmsWatched
                ),
                profileURL: stats.topActor.profileURL
            ),
            monthlyActivity: StatsModels.MonthlyActivityViewModel(
                title: Strings.StatsScene.MonthlyActivity.title,
                subtitle: Strings.StatsScene.MonthlyActivity.subtitle,
                bars: stats.monthlyActivity.map { month in
                    let relative = maxMonthly > 0
                        ? Double(month.filmsCount) / Double(maxMonthly)
                        : 0
                    return StatsModels.MonthlyBarViewModel(
                        monthLabel: monthLabel(for: month.monthIndex),
                        valueText: "\(month.filmsCount)",
                        relativeHeight: max(relative, 0.08)
                    )
                }
            )
        )
    }

    private func genreName(for id: GenreStatID) -> String {
        switch id {
        case .drama: Strings.StatsScene.Genre.drama
        case .sciFi: Strings.StatsScene.Genre.sciFi
        case .thriller: Strings.StatsScene.Genre.thriller
        case .comedy: Strings.StatsScene.Genre.comedy
        case .other: Strings.StatsScene.Genre.other
        }
    }

    private func genreTone(for id: GenreStatID) -> StatsModels.GenreTone {
        switch id {
        case .drama, .sciFi:
            .accent
        case .thriller:
            .pink
        case .comedy:
            .cyan
        case .other:
            .muted
        }
    }

    private func monthLabel(for monthIndex: Int) -> String {
        var components = DateComponents()
        components.month = monthIndex
        components.day = 1
        components.year = 2000
        guard let date = Calendar.current.date(from: components) else {
            return ""
        }
        let full = monthFormatter.string(from: date)
        return String(full.prefix(1)).uppercased()
    }
}
