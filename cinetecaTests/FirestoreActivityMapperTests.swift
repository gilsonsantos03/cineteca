import XCTest
@testable import cineteca

final class FirestoreActivityMapperTests: XCTestCase {
    func testMetadataDataDoesNotWriteOptionalNilValues() {
        let metadata = MovieActivityMetadata(
            movieId: 42,
            title: "A movie",
            posterURL: nil,
            backdropURL: nil,
            runtimeMinutes: nil,
            releaseYear: nil,
            genres: [Genre(id: 18, name: "Drama")],
            directorNames: [],
            actorNames: []
        )

        let data = FirestoreActivityRecord.metadataData(metadata)

        XCTAssertEqual(data["movieId"] as? Int, 42)
        XCTAssertNil(data["posterURL"])
        XCTAssertNil(data["backdropURL"])
        XCTAssertNil(data["runtimeMinutes"])
        XCTAssertNil(data["releaseYear"])
    }
}
