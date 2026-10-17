import Foundation

protocol ListsBusinessLogic {
    func fetchContent(request: ListsModels.FetchContent.Request)
    func selectList(request: ListsModels.SelectList.Request)
    func removeMovie(request: ListsModels.RemoveMovie.Request)
}

final class ListsInteractor {
    private let presenter: ListsPresentationLogic
    private let activityRepository: MovieActivityRepositoryProtocol

    private var activities: [MovieActivity] = []
    private var selectedList: ListsModels.List = .watchlist

    init(
        presenter: ListsPresentationLogic,
        activityRepository: MovieActivityRepositoryProtocol
    ) {
        self.presenter = presenter
        self.activityRepository = activityRepository
    }
}

extension ListsInteractor: ListsBusinessLogic {
    func fetchContent(request: ListsModels.FetchContent.Request) {
        presenter.presentLoading()
        Task {
            let response: ListsModels.FetchContent.Response
            do {
                response = .content(
                    activities: try await activityRepository.fetchActivities(),
                    selectedList: selectedList
                )
            } catch {
                response = .error
            }

            await MainActor.run {
                if case let .content(activities: activities, selectedList: _) = response {
                    self.activities = activities
                }
                self.presenter.presentFetchContent(response: response)
            }
        }
    }

    func selectList(request: ListsModels.SelectList.Request) {
        guard request.list != selectedList else { return }
        selectedList = request.list
        presenter.presentFetchContent(
            response: .content(activities: activities, selectedList: selectedList)
        )
    }

    func removeMovie(request: ListsModels.RemoveMovie.Request) {
        let list = selectedList
        Task {
            let response: ListsModels.RemoveMovie.Response
            do {
                switch list {
                case .watchlist:
                    _ = try await activityRepository.setWatchlist(false, for: request.movieId)
                case .favorites:
                    _ = try await activityRepository.setFavorite(false, for: request.movieId)
                case .rated:
                    _ = try await activityRepository.unrateMovie(for: request.movieId)
                }
                response = .content(
                    activities: try await activityRepository.fetchActivities(),
                    selectedList: list
                )
            } catch {
                response = .error
            }

            await MainActor.run {
                if case let .content(activities: activities, selectedList: _) = response {
                    self.activities = activities
                }
                self.presenter.presentRemoveMovie(response: response)
            }
        }
    }
}
