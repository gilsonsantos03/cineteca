import Foundation

protocol MyReviewsBusinessLogic {
    func fetchReviews(request: MyReviewsModels.FetchReviews.Request)
    func updateReview(request: MyReviewsModels.UpdateReview.Request)
}

final class MyReviewsInteractor {
    private let presenter: MyReviewsPresentationLogic
    private let userRepository: UserRepositoryProtocol
    private let activityRepository: MovieActivityRepositoryProtocol

    init(
        presenter: MyReviewsPresentationLogic,
        userRepository: UserRepositoryProtocol,
        activityRepository: MovieActivityRepositoryProtocol
    ) {
        self.presenter = presenter
        self.userRepository = userRepository
        self.activityRepository = activityRepository
    }
}

extension MyReviewsInteractor: MyReviewsBusinessLogic {
    func fetchReviews(request: MyReviewsModels.FetchReviews.Request) {
        presenter.presentLoading()
        Task {
            let response: MyReviewsModels.FetchReviews.Response
            do {
                response = .content(try await userRepository.fetchCurrentUser())
            } catch {
                response = .error
            }
            await MainActor.run {
                presenter.presentFetchReviews(response: response)
            }
        }
    }

    func updateReview(request: MyReviewsModels.UpdateReview.Request) {
        Task {
            let response: MyReviewsModels.UpdateReview.Response
            do {
                try await activityRepository.upsertMetadata(request.metadata)
                _ = try await activityRepository.rateMovie(
                    for: request.metadata.movieId,
                    rating: request.rating
                )
                try await activityRepository.saveReview(
                    for: request.metadata.movieId,
                    rating: request.rating,
                    text: request.reviewText ?? ""
                )
                response = .content(try await userRepository.fetchCurrentUser())
            } catch {
                response = .error
            }
            await MainActor.run {
                presenter.presentUpdateReview(response: response)
            }
        }
    }
}
