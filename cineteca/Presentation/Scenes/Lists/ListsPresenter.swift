import Foundation

protocol ListsPresentationLogic {
    func presentFetchContent(response: ListsModels.FetchContent.Response)
    func presentRemoveMovie(response: ListsModels.RemoveMovie.Response)
    func presentLoading()
}

final class ListsPresenter {
    weak var view: ListsDisplayLogic?
}

extension ListsPresenter: ListsPresentationLogic {
    func presentFetchContent(response: ListsModels.FetchContent.Response) {
        switch response {
        case let .content(activities, selectedList):
            view?.displayFetchContent(
                viewModel: .content(
                    makeContent(from: activities, selectedList: selectedList)
                )
            )
        case .error:
            view?.displayFetchContent(viewModel: .error)
        }
    }

    func presentRemoveMovie(response: ListsModels.RemoveMovie.Response) {
        switch response {
        case let .content(activities, selectedList):
            view?.displayRemoveMovie(
                viewModel: .content(
                    makeContent(from: activities, selectedList: selectedList)
                )
            )
        case .error:
            view?.displayRemoveMovie(viewModel: .error)
        }
    }

    func presentLoading() {
        view?.displayLoading()
    }

    private func makeContent(
        from activities: [MovieActivity],
        selectedList: ListsModels.List
    ) -> ListsModels.FetchContent.ViewModel.Content {
        let movies = activities
            .filter { belongsToSelectedList($0, selectedList: selectedList) }
            .map(makeMovieCardViewModel)

        return ListsModels.FetchContent.ViewModel.Content(
            selectedList: selectedList,
            movies: movies
        )
    }

    private func makeMovieCardViewModel(
        from activity: MovieActivity
    ) -> ListsModels.MovieCardViewModel {
        let metadata = [
            activity.metadata.releaseYear,
            formatRuntime(activity.metadata.runtimeMinutes)
        ]
        .compactMap { $0 }
        .joined(separator: " • ")

        return ListsModels.MovieCardViewModel(
            movieId: activity.metadata.movieId,
            title: activity.metadata.title,
            metadata: metadata,
            genres: activity.metadata.genres.map(\.name),
            posterURL: activity.metadata.posterURL,
            rating: activity.rating.map(formatRating)
        )
    }

    private func formatRating(_ rating: Double) -> String {
        rating == rating.rounded()
            ? String(format: "%.0f", rating)
            : String(format: "%.1f", rating)
    }

    private func belongsToSelectedList(
        _ activity: MovieActivity,
        selectedList: ListsModels.List
    ) -> Bool {
        switch selectedList {
        case .watchlist:
            activity.isInWatchlist
        case .favorites:
            activity.isFavorite
        case .rated:
            activity.isRated
        }
    }

    private func formatRuntime(_ runtimeMinutes: Int?) -> String? {
        guard let runtimeMinutes, runtimeMinutes > 0 else { return nil }
        return String(
            format: Strings.ListsScene.Card.durationFormat,
            runtimeMinutes / 60,
            runtimeMinutes % 60
        )
    }
}
