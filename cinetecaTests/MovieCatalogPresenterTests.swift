import XCTest
@testable import cineteca

final class MovieCatalogPresenterTests: XCTestCase {
    func testPresentContentMapsMovieToCatalogCard() {
        let presenter = MovieCatalogPresenter()
        let view = SpyMovieCatalogView()
        presenter.view = view

        presenter.presentFetchContent(
            response: .content(
                page: MovieCollectionPage(
                    movies: [
                        Movie(
                            id: 101,
                            title: "Movie 101",
                            posterURL: URL(string: "https://example.com/poster.jpg"),
                            backdropURL: nil,
                            releaseYear: "2024",
                            rating: 8.7,
                            genres: [],
                            runtime: nil
                        )
                    ],
                    page: 1,
                    totalPages: 2
                ),
                genres: []
            )
        )

        guard case let .content(content) = view.fetchViewModel else {
            return XCTFail("Expected content view model")
        }

        XCTAssertEqual(content.movies.count, 1)
        XCTAssertEqual(content.movies[0].id, 101)
        XCTAssertEqual(content.movies[0].title, "Movie 101")
        XCTAssertEqual(content.movies[0].year, "2024")
        XCTAssertEqual(content.movies[0].rating, "8.7")
        XCTAssertTrue(content.hasMorePages)
    }

    func testPresentErrorReturnsErrorViewModel() {
        let presenter = MovieCatalogPresenter()
        let view = SpyMovieCatalogView()
        presenter.view = view

        presenter.presentFetchContent(response: .error)

        guard case .error = view.fetchViewModel else {
            return XCTFail("Expected error view model")
        }
    }

    func testMovieListResponseDecodesPaginationMetadata() throws {
        let data = Data(
            """
            {
              "page": 1,
              "total_pages": 12,
              "total_results": 240,
              "results": []
            }
            """.utf8
        )

        let response = try JSONDecoder.snakeCase.decode(MovieListResponse.self, from: data)

        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 12)
        XCTAssertEqual(response.totalResults, 240)
    }
}

private final class SpyMovieCatalogView: MovieCatalogDisplayLogic {
    var fetchViewModel: MovieCatalogModels.FetchContent.ViewModel?

    func displayFetchContent(viewModel: MovieCatalogModels.FetchContent.ViewModel) {
        fetchViewModel = viewModel
    }

    func displayFetchNextPage(viewModel: MovieCatalogModels.FetchNextPage.ViewModel) {}

    func displayLoading() {}

    func displayLoadingNextPage() {}
}
