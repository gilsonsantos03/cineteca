import Foundation

protocol MyReviewsPresentationLogic {
    func presentFetchReviews(response: MyReviewsModels.FetchReviews.Response)
    func presentUpdateReview(response: MyReviewsModels.UpdateReview.Response)
    func presentLoading()
}

final class MyReviewsPresenter {
    weak var view: MyReviewsDisplayLogic?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

extension MyReviewsPresenter: MyReviewsPresentationLogic {
    func presentFetchReviews(response: MyReviewsModels.FetchReviews.Response) {
        switch response {
        case let .content(user):
            view?.displayFetchReviews(viewModel: .content(makeContent(from: user)))
        case .error:
            view?.displayFetchReviews(viewModel: .error)
        }
    }

    func presentUpdateReview(response: MyReviewsModels.UpdateReview.Response) {
        switch response {
        case let .content(user):
            view?.displayUpdateReview(viewModel: .content(makeContent(from: user)))
        case .error:
            view?.displayUpdateReview(viewModel: .error)
        }
    }

    func presentLoading() {
        view?.displayLoading()
    }

    private func makeContent(from user: User) -> MyReviewsModels.FetchReviews.ViewModel.Content {
        MyReviewsModels.FetchReviews.ViewModel.Content(
            reviews: user.reviews.map { review in
                MyReviewsModels.ReviewCardViewModel(
                    movieId: review.movieId,
                    title: review.title,
                    metadata: [review.releaseYear, review.directorName]
                        .compactMap { $0 }
                        .filter { !$0.isEmpty }
                        .joined(separator: " • "),
                    releaseYear: review.releaseYear,
                    directorName: review.directorName,
                    posterURL: review.posterURL,
                    rating: review.rating,
                    reviewText: review.reviewText,
                    dateText: review.reviewDate.map(dateFormatter.string(from:)) ?? ""
                )
            }
        )
    }
}
