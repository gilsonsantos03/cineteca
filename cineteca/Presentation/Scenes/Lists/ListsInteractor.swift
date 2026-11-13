import Foundation

protocol ListsBusinessLogic {
    func fetchContent(request: ListsModels.FetchContent.Request)
    func selectList(request: ListsModels.SelectList.Request)
    func removeMovie(request: ListsModels.RemoveMovie.Request)
}

final class ListsInteractor {
    private let presenter: ListsPresentationLogic
    private let activityRepository: MovieActivityRepositoryProtocol

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
        let cachedActivities = activityRepository.cachedActivities()
        if let cachedActivities {
            presenter.presentFetchContent(
                response: .content(activities: cachedActivities, selectedList: selectedList)
            )
        } else {
            presenter.presentLoading()
        }

        Task {
            do {
                let activities = try await activityRepository.fetchActivities()
                await MainActor.run {
                    presenter.presentFetchContent(
                        response: .content(activities: activities, selectedList: selectedList)
                    )
                }
            } catch AuthenticationError.userNotAuthenticated {
                return
            } catch {
                guard cachedActivities == nil else { return }
                await MainActor.run {
                    presenter.presentFetchContent(response: .error)
                }
            }
        }
    }

    func selectList(request: ListsModels.SelectList.Request) {
        guard request.list != selectedList else { return }
        selectedList = request.list
        guard let activities = activityRepository.cachedActivities() else { return }
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
                self.presenter.presentRemoveMovie(response: response)
            }
        }
    }
}
