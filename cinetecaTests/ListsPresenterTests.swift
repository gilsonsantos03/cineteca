import XCTest
@testable import cineteca

final class ListsPresenterTests: XCTestCase {
    func testPresentContentFiltersWatchlistActivities() {
        let presenter = ListsPresenter()
        let view = SpyListsView()
        presenter.view = view

        presenter.presentFetchContent(
            response: .content(
                activities: [
                    makeActivity(movieId: 101, isInWatchlist: true),
                    makeActivity(movieId: 202, isFavorite: true)
                ],
                selectedList: .watchlist
            )
        )

        guard case let .content(content) = view.fetchViewModel else {
            return XCTFail("Expected content view model")
        }
        XCTAssertEqual(content.movies.map(\.movieId), [101])
    }

    func testPresentContentReturnsEmptyRatedList() {
        let presenter = ListsPresenter()
        let view = SpyListsView()
        presenter.view = view

        presenter.presentFetchContent(
            response: .content(
                activities: [makeActivity(movieId: 101, isInWatchlist: true)],
                selectedList: .rated
            )
        )

        guard case let .content(content) = view.fetchViewModel else {
            return XCTFail("Expected content view model")
        }
        XCTAssertTrue(content.movies.isEmpty)
    }

    private func makeActivity(
        movieId: Int,
        rating: Double? = nil,
        isFavorite: Bool = false,
        isInWatchlist: Bool = false
    ) -> MovieActivity {
        MovieActivity(
            metadata: MovieActivityMetadata(
                movieId: movieId,
                title: "Movie \(movieId)",
                posterURL: nil,
                backdropURL: nil,
                runtimeMinutes: 120,
                releaseYear: "2024",
                genres: [Genre(id: 18, name: "Drama")],
                directorNames: [],
                actorNames: []
            ),
            rating: rating,
            ratedAt: rating == nil ? nil : Date(),
            isFavorite: isFavorite,
            isInWatchlist: isInWatchlist,
            updatedAt: Date()
        )
    }
}

private final class SpyListsView: ListsDisplayLogic {
    var fetchViewModel: ListsModels.FetchContent.ViewModel?

    func displayFetchContent(viewModel: ListsModels.FetchContent.ViewModel) {
        fetchViewModel = viewModel
    }

    func displayRemoveMovie(viewModel: ListsModels.RemoveMovie.ViewModel) {}

    func displayLoading() {}
}
