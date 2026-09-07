import CoreData

@objc(ReviewEntity)
final class ReviewEntity: NSManagedObject {
    @NSManaged var movieId: Int32
    @NSManaged var title: String
    @NSManaged var posterPath: String?
    @NSManaged var rating: Double
    @NSManaged var reviewText: String
    @NSManaged var sortOrder: Int16
    @NSManaged var user: UserEntity?
}

extension ReviewEntity {
    @nonobjc static func fetchRequest() -> NSFetchRequest<ReviewEntity> {
        NSFetchRequest<ReviewEntity>(entityName: "ReviewEntity")
    }

    func toDomain() -> UserReview {
        UserReview(
            movieId: Int(movieId),
            title: title,
            posterURL: posterPath.flatMap { URL(string: TMDBImage.posterBaseURL + $0) },
            rating: rating,
            reviewText: reviewText
        )
    }
}
