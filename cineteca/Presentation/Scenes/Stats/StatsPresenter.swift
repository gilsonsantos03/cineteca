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
        case let .content(history, periods, selectedPeriod):
            guard let content = makeContent(
                history: history,
                periods: periods,
                selectedPeriod: selectedPeriod
            ) else {
                view?.displayFetchStats(viewModel: .error)
                return
            }
            view?.displayFetchStats(viewModel: .content(content))
        case .error:
            view?.displayFetchStats(viewModel: .error)
        }
    }

    func presentLoading() {
        view?.displayLoading()
    }

    private func makeContent(
        history: FilmStatsHistory,
        periods: [StatsModels.Period],
        selectedPeriod: StatsModels.Period
    ) -> StatsModels.FetchStats.ViewModel.Content? {
        let stats: FilmStats
        let header: StatsModels.HeaderViewModel
        switch selectedPeriod {
        case .allTime:
            stats = history.allTime
            header = StatsModels.HeaderViewModel(
                periodText: Strings.StatsScene.AllTime.label,
                title: Strings.StatsScene.AllTime.title
            )
        case let .year(year):
            guard let yearStats = history.statsByYear[year] else { return nil }
            stats = yearStats
            header = StatsModels.HeaderViewModel(
                periodText: "\(year)",
                title: Strings.StatsScene.title
            )
        }

        return StatsModels.FetchStats.ViewModel.Content(
            header: header,
            periodFilter: StatsModels.PeriodFilterViewModel(
                options: periods.map(periodTitle),
                selectedIndex: periods.firstIndex(of: selectedPeriod) ?? 0
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
            activity: makeActivity(from: stats.activity)
        )
    }

    private func periodTitle(for period: StatsModels.Period) -> String {
        switch period {
        case .allTime: Strings.StatsScene.AllTime.chip
        case let .year(year): "\(year)"
        }
    }

    private func makeActivity(from activity: FilmActivity) -> StatsModels.ActivityViewModel {
        switch activity {
        case let .monthly(months):
            StatsModels.ActivityViewModel(
                title: Strings.StatsScene.MonthlyActivity.title,
                subtitle: Strings.StatsScene.MonthlyActivity.subtitle,
                bars: makeBars(months.map { (monthLabel(for: $0.monthIndex), $0.filmsCount) })
            )
        case let .yearly(years):
            StatsModels.ActivityViewModel(
                title: Strings.StatsScene.YearlyActivity.title,
                subtitle: Strings.StatsScene.YearlyActivity.subtitle,
                bars: makeBars(years.map { ("\($0.year)", $0.filmsCount) })
            )
        }
    }

    private func makeBars(_ values: [(label: String, count: Int)]) -> [StatsModels.ActivityBarViewModel] {
        let maxCount = values.map(\.count).max() ?? 0
        return values.map { value in
            let relative = maxCount > 0 ? Double(value.count) / Double(maxCount) : 0
            return StatsModels.ActivityBarViewModel(
                label: value.label,
                valueText: "\(value.count)",
                relativeHeight: max(relative, 0.08)
            )
        }
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
