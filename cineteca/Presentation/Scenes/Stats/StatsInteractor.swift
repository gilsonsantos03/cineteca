import Foundation

protocol StatsBusinessLogic {
    func fetchStats(request: StatsModels.FetchStats.Request)
    func selectPeriod(request: StatsModels.SelectPeriod.Request)
}

final class StatsInteractor {
    private let presenter: StatsPresentationLogic
    private let statsRepository: StatsRepositoryProtocol

    private var selectedPeriod: StatsModels.Period?

    init(presenter: StatsPresentationLogic, statsRepository: StatsRepositoryProtocol) {
        self.presenter = presenter
        self.statsRepository = statsRepository
    }
}

extension StatsInteractor: StatsBusinessLogic {
    func fetchStats(request: StatsModels.FetchStats.Request) {
        let cachedHistory = statsRepository.cachedFilmStatsHistory()
        if let cachedHistory {
            presentContent(history: cachedHistory)
        } else {
            selectedPeriod = nil
            presenter.presentLoading()
        }

        Task {
            do {
                let history = try await statsRepository.fetchFilmStatsHistory()
                await MainActor.run {
                    presentContent(history: history)
                }
            } catch AuthenticationError.userNotAuthenticated {
                return
            } catch {
                guard cachedHistory == nil else { return }
                await MainActor.run {
                    presenter.presentFetchStats(response: .error)
                }
            }
        }
    }

    func selectPeriod(request: StatsModels.SelectPeriod.Request) {
        guard let history = statsRepository.cachedFilmStatsHistory() else { return }
        let periods = Self.periods(for: history)
        guard periods.indices.contains(request.index) else { return }
        selectedPeriod = periods[request.index]
        presentContent(history: history)
    }

    private func presentContent(history: FilmStatsHistory) {
        let periods = Self.periods(for: history)
        let period: StatsModels.Period
        if let selectedPeriod, periods.contains(selectedPeriod) {
            period = selectedPeriod
        } else {
            period = .year(history.currentYear)
        }
        selectedPeriod = period
        presenter.presentFetchStats(
            response: .content(history: history, periods: periods, selectedPeriod: period)
        )
    }

    private static func periods(for history: FilmStatsHistory) -> [StatsModels.Period] {
        [.allTime] + history.years.map { .year($0) }
    }
}
