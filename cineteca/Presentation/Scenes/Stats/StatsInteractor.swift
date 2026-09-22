import Foundation

protocol StatsBusinessLogic {
    func fetchStats(request: StatsModels.FetchStats.Request)
}

final class StatsInteractor {
    private let presenter: StatsPresentationLogic
    private let statsRepository: StatsRepositoryProtocol

    init(presenter: StatsPresentationLogic, statsRepository: StatsRepositoryProtocol) {
        self.presenter = presenter
        self.statsRepository = statsRepository
    }
}

extension StatsInteractor: StatsBusinessLogic {
    func fetchStats(request: StatsModels.FetchStats.Request) {
        presenter.presentLoading()
        Task {
            let response: StatsModels.FetchStats.Response
            do {
                let stats = try await statsRepository.fetchYearInFilmStats()
                response = .content(stats)
            } catch {
                response = .error
            }
            await MainActor.run {
                presenter.presentFetchStats(response: response)
            }
        }
    }
}
