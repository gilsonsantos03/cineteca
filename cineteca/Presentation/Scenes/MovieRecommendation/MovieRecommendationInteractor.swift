import Foundation

protocol MovieRecommendationBusinessLogic {
    func generate(request: MovieRecommendationModels.Generate.Request)
}

protocol MovieRecommendationPresentationLogic {
    func presentLoading()
    func presentGenerate(response: MovieRecommendationModels.Generate.Response)
}

final class MovieRecommendationInteractor: MovieRecommendationBusinessLogic {
    private let presenter: MovieRecommendationPresentationLogic
    private let recommendationRepository: MovieRecommendationRepositoryProtocol
    private let movieRepository: MovieRepositoryProtocol
    private var recommendationTask: Task<Void, Never>?

    init(
        presenter: MovieRecommendationPresentationLogic,
        recommendationRepository: MovieRecommendationRepositoryProtocol,
        movieRepository: MovieRepositoryProtocol
    ) {
        self.presenter = presenter
        self.recommendationRepository = recommendationRepository
        self.movieRepository = movieRepository
    }

    deinit {
        recommendationTask?.cancel()
    }

    func generate(request: MovieRecommendationModels.Generate.Request) {
        recommendationTask?.cancel()
        presenter.presentLoading()
        recommendationTask = Task { [weak self] in
            await self?.loadRecommendation(for: request.mode)
        }
    }

    private func loadRecommendation(for mode: MovieRecommendationMode) async {
        do {
            let recommendation = try await recommendationRepository.recommend(mode: mode)
            guard !Task.isCancelled else { return }
            let details = try await movieRepository.fetchMovieDetails(for: recommendation.movieID)
            guard !Task.isCancelled else { return }
            let movie = Movie(
                id: details.id,
                title: details.title,
                posterURL: details.posterURL,
                backdropURL: details.backdropURL,
                releaseYear: details.releaseYear,
                rating: details.rating,
                genres: details.genres,
                runtime: details.runtime
            )
            await MainActor.run {
                presenter.presentGenerate(response: .content(recommendation: recommendation, movie: movie))
            }
        } catch let error as MovieRecommendationError {
            guard !Task.isCancelled else { return }
            await MainActor.run { presenter.presentGenerate(response: .error(error)) }
        } catch {
            guard !Task.isCancelled else { return }
            await MainActor.run {
                presenter.presentGenerate(response: .error(.unavailable))
            }
        }
    }
}
