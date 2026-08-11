import Foundation

protocol MovieDetailsBusinessLogic {
    func fetchDetails(request: MovieDetailsModels.FetchDetails.Request)
    func watchTrailer(request: MovieDetailsModels.WatchTrailer.Request)
}

final class MovieDetailsInteractor {
    private let presenter: MovieDetailsPresentationLogic
    private let repository: MovieRepositoryProtocol

    init(presenter: MovieDetailsPresentationLogic, repository: MovieRepositoryProtocol) {
        self.presenter = presenter
        self.repository = repository
    }
}

extension MovieDetailsInteractor: MovieDetailsBusinessLogic {
    func fetchDetails(request: MovieDetailsModels.FetchDetails.Request) {
        presenter.presentLoading()
        Task {
            do {
                let movie = try await repository.fetchMovieDetails(for: request.movieId)
                await MainActor.run {
                    presenter.presentDetails(response: .init(movie: movie))
                }
            } catch {
                await MainActor.run {
                    presenter.presentError(error)
                }
            }
        }
    }

    func watchTrailer(request: MovieDetailsModels.WatchTrailer.Request) {
        Task {
            let response: MovieDetailsModels.WatchTrailer.Response
            do {
                if let youtubeKey = try await repository.fetchTrailerKey(for: request.movieId) {
                    response = .success(youtubeKey: youtubeKey)
                } else {
                    response = .unavailable
                }
            } catch {
                response = .unavailable
            }
            await MainActor.run { presenter.presentWatchTrailer(response: response) }
        }
    }
}
