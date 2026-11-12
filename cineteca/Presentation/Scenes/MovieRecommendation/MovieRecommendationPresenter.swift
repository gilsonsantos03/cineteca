import Foundation

final class MovieRecommendationPresenter: MovieRecommendationPresentationLogic {
    weak var view: MovieRecommendationDisplayLogic?

    func presentLoading() {
        view?.displayLoading()
    }

    func presentGenerate(response: MovieRecommendationModels.Generate.Response) {
        switch response {
        case let .content(recommendation, movie):
            view?.displayGenerate(
                viewModel: .content(
                    MovieRecommendationModels.Generate.ResultViewModel(
                        movieID: movie.id,
                        title: movie.title,
                        year: movie.releaseYear,
                        rating: String(format: "%.1f", movie.rating),
                        posterURL: movie.posterURL,
                        explanation: recommendation.explanation
                    )
                )
            )
        case let .error(error):
            let message: String
            switch error {
            case .invalidInput:
                message = Strings.MovieRecommendationScene.invalidInput
            case .rateLimited:
                message = Strings.MovieRecommendationScene.rateLimited
            case .unavailable:
                message = Strings.MovieRecommendationScene.errorMessage
            }
            view?.displayGenerate(viewModel: .error(message))
        }
    }
}
