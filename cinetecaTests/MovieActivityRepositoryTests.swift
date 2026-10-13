import XCTest
@testable import cineteca

final class MovieActivityRepositoryTests: XCTestCase {
    private var coreDataStack: CoreDataStack!
    private var repository: MovieActivityRepository!

    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack(inMemory: true)
        repository = MovieActivityRepository(coreDataStack: coreDataStack)
    }

    override func tearDown() {
        repository = nil
        coreDataStack = nil
        super.tearDown()
    }

    func testFavoriteRequiresRating() async throws {
        try await repository.upsertMetadata(makeMetadata())

        do {
            _ = try await repository.setFavorite(true, for: 101)
            XCTFail("Expected favorite to require a rating")
        } catch MovieActivityRepositoryError.favoriteRequiresRating {
            // Expected.
        }
    }

    func testRatingMarksFilmAsWatchedAndEnablesFavorite() async throws {
        try await repository.upsertMetadata(makeMetadata())

        let activity = try await repository.rateMovie(for: 101, rating: 8.0)

        XCTAssertEqual(activity.rating, 8.0)
        XCTAssertTrue(activity.isRated)
        XCTAssertFalse(activity.isFavorite)

        let favorite = try await repository.setFavorite(true, for: 101)
        XCTAssertTrue(favorite.isFavorite)
    }

    func testWatchlistToggleIsIdempotent() async throws {
        try await repository.upsertMetadata(makeMetadata())

        let added = try await repository.setWatchlist(true, for: 101)
        XCTAssertTrue(added.isInWatchlist)

        let removed = try await repository.setWatchlist(false, for: 101)
        XCTAssertFalse(removed.isInWatchlist)
    }

    func testStatsAggregateRatedActivities() async throws {
        try await repository.upsertMetadata(makeMetadata())
        _ = try await repository.rateMovie(for: 101, rating: 4.0)

        let statsRepository = StatsRepository(
            activityRepository: repository,
            coreDataStack: coreDataStack
        )
        let stats = try await statsRepository.fetchYearInFilmStats()

        XCTAssertEqual(stats.filmsCount, 1)
        XCTAssertEqual(stats.hoursWatched, 2)
        XCTAssertEqual(stats.genres.first?.id, .drama)
        XCTAssertEqual(stats.monthlyActivity.reduce(0) { $0 + $1.filmsCount }, 1)
    }

    func testProfileUsesRatedActivities() async throws {
        try await repository.upsertMetadata(makeMetadata())
        _ = try await repository.rateMovie(for: 101, rating: 4.0)
        _ = try await repository.setFavorite(true, for: 101)

        let userRepository = UserRepository(
            coreDataStack: coreDataStack,
            activityRepository: repository
        )
        let user = try await userRepository.fetchCurrentUser()

        XCTAssertEqual(user.stats.filmsCount, 1)
        XCTAssertEqual(user.stats.hoursWatched, 2)
        XCTAssertEqual(user.favoriteFilm?.movieId, 101)
    }

    func testProfileIncludesRatingWithoutReviewText() async throws {
        try await repository.upsertMetadata(makeMetadata())
        _ = try await repository.rateMovie(for: 101, rating: 8.0)

        let userRepository = UserRepository(
            coreDataStack: coreDataStack,
            activityRepository: repository
        )
        let user = try await userRepository.fetchCurrentUser()

        let ratingOnlyReview = try XCTUnwrap(
            user.reviews.first { $0.movieId == 101 }
        )
        XCTAssertEqual(ratingOnlyReview.rating, 8.0)
        XCTAssertTrue(ratingOnlyReview.reviewText.isEmpty)
        XCTAssertEqual(user.recentReviews.first?.movieId, 101)
    }

    func testReviewIsPersistedWithOptionalText() async throws {
        try await repository.upsertMetadata(makeMetadata())
        _ = try await repository.rateMovie(for: 101, rating: 4.0)

        let userRepository = UserRepository(
            coreDataStack: coreDataStack,
            activityRepository: repository
        )
        let initialUser = try await userRepository.fetchCurrentUser()

        try await repository.saveReview(for: 101, rating: 4.0, text: "A great film")

        let user = try await userRepository.fetchCurrentUser()

        XCTAssertEqual(user.stats.reviewsCount, initialUser.stats.reviewsCount)
        XCTAssertTrue(user.recentReviews.contains { $0.reviewText == "A great film" })
        XCTAssertTrue(user.recentReviews.contains { $0.rating == 4.0 })
    }

    func testRecentReviewsAreLimitedAndNewestReviewComesFirst() async throws {
        try await repository.upsertMetadata(makeMetadata())
        _ = try await repository.rateMovie(for: 101, rating: 8.0)
        try await repository.saveReview(for: 101, rating: 8.0, text: "Newest review")

        let userRepository = UserRepository(
            coreDataStack: coreDataStack,
            activityRepository: repository
        )
        let user = try await userRepository.fetchCurrentUser()

        XCTAssertEqual(user.recentReviews.count, 3)
        XCTAssertEqual(user.recentReviews.first?.reviewText, "Newest review")
        XCTAssertEqual(user.stats.reviewsCount, 4)
    }

    func testEmptyReviewTextDoesNotCreateReview() async throws {
        try await repository.upsertMetadata(makeMetadata())
        _ = try await repository.rateMovie(for: 101, rating: 4.0)

        let userRepository = UserRepository(
            coreDataStack: coreDataStack,
            activityRepository: repository
        )
        let initialUser = try await userRepository.fetchCurrentUser()

        try await repository.saveReview(for: 101, rating: 4.0, text: "   ")

        let user = try await userRepository.fetchCurrentUser()

        XCTAssertEqual(user.stats.reviewsCount, initialUser.stats.reviewsCount)
    }

    func testReviewCanBeUpdatedWithoutCreatingADuplicate() async throws {
        try await repository.upsertMetadata(makeMetadata())
        let userRepository = UserRepository(
            coreDataStack: coreDataStack,
            activityRepository: repository
        )
        let initialUser = try await userRepository.fetchCurrentUser()

        _ = try await repository.rateMovie(for: 101, rating: 4.0)
        try await repository.saveReview(for: 101, rating: 4.0, text: "Original review")

        _ = try await repository.rateMovie(for: 101, rating: 9.0)
        try await repository.saveReview(for: 101, rating: 9.0, text: "Updated review")

        let user = try await userRepository.fetchCurrentUser()

        XCTAssertEqual(user.reviews.count, initialUser.reviews.count + 1)
        XCTAssertEqual(user.reviews.first?.reviewText, "Updated review")
        XCTAssertEqual(user.reviews.first?.rating, 9.0)
        XCTAssertEqual(user.reviews.first?.releaseYear, "2024")
    }

    func testRatingSupportsTenPointScale() async throws {
        try await repository.upsertMetadata(makeMetadata())

        let activity = try await repository.rateMovie(for: 101, rating: 10.0)

        XCTAssertEqual(activity.rating, 10.0)
    }

    func testRatingSupportsZeroAsNotForMe() async throws {
        try await repository.upsertMetadata(makeMetadata())

        let activity = try await repository.rateMovie(for: 101, rating: 0.0)

        XCTAssertEqual(activity.rating, 0.0)
        XCTAssertTrue(activity.isRated)
    }

    func testResetSessionDataClearsActivitiesAndReviews() async throws {
        try await repository.upsertMetadata(makeMetadata())
        _ = try await repository.rateMovie(for: 101, rating: 8.0)
        try await repository.saveReview(for: 101, rating: 8.0, text: "Great film")
        _ = try await repository.setFavorite(true, for: 101)
        _ = try await repository.setWatchlist(true, for: 101)

        try repository.resetSessionData()

        let activities = try await repository.fetchActivities()
        XCTAssertTrue(activities.isEmpty)

        let userRepository = UserRepository(
            coreDataStack: coreDataStack,
            activityRepository: repository
        )
        let user = try await userRepository.fetchCurrentUser()
        XCTAssertNil(user.favoriteFilm)
        XCTAssertEqual(user.stats.filmsCount, 0)
        XCTAssertEqual(user.stats.reviewsCount, 0)
        XCTAssertTrue(user.reviews.isEmpty)
    }

    func testRatingRejectsValuesAboveTen() async throws {
        try await repository.upsertMetadata(makeMetadata())

        do {
            _ = try await repository.rateMovie(for: 101, rating: 10.5)
            XCTFail("Expected ratings above ten to be rejected")
        } catch MovieActivityRepositoryError.invalidRating {
            // Expected.
        }
    }

    func testRatingRejectsFractionalValues() async throws {
        try await repository.upsertMetadata(makeMetadata())

        do {
            _ = try await repository.rateMovie(for: 101, rating: 2.5)
            XCTFail("Expected fractional ratings to be rejected")
        } catch MovieActivityRepositoryError.invalidRating {
            // Expected.
        }
    }

    private func makeMetadata() -> MovieActivityMetadata {
        MovieActivityMetadata(
            movieId: 101,
            title: "Test movie",
            posterURL: nil,
            backdropURL: nil,
            runtimeMinutes: 120,
            releaseYear: "2024",
            genres: [Genre(id: 18, name: "Drama")],
            directorNames: ["Test Director"],
            actorNames: ["Test Actor"]
        )
    }
}
