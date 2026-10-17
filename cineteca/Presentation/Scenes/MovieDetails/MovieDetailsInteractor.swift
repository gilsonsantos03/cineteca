import Foundation

protocol MovieDetailsBusinessLogic {
    func fetchDetails(request: MovieDetailsModels.FetchDetails.Request)
    func watchTrailer(request: MovieDetailsModels.WatchTrailer.Request)
    func fetchReview(request: MovieDetailsModels.FetchReview.Request)
    func updateActivity(request: MovieDetailsModels.UpdateActivity.Request)
}

final class MovieDetailsInteractor {
    private let presenter: MovieDetailsPresentationLogic
    private let repository: MovieRepositoryProtocol
    private let activityRepository: MovieActivityRepositoryProtocol

    init(
        presenter: MovieDetailsPresentationLogic,
        repository: MovieRepositoryProtocol,
        activityRepository: MovieActivityRepositoryProtocol
    ) {
        self.presenter = presenter
        self.repository = repository
        self.activityRepository = activityRepository
    }
}

extension MovieDetailsInteractor: MovieDetailsBusinessLogic {
    func fetchDetails(request: MovieDetailsModels.FetchDetails.Request) {
        presenter.presentLoading()
        Task {
            do {
                let movie = try await repository.fetchMovieDetails(for: request.movieId)
                let metadata = Self.makeActivityMetadata(from: movie)
                let activity: MovieActivity
                do {
                    try await activityRepository.upsertMetadata(metadata)
                    activity = try await activityRepository.fetchActivity(for: movie.id)
                        ?? Self.makeEmptyActivity(metadata: metadata)
                } catch {
                    activity = Self.makeEmptyActivity(metadata: metadata)
                }
                await MainActor.run {
                    presenter.presentFetchDetails(response: .content(movie: movie, activity: activity))
                }
            } catch {
                await MainActor.run {
                    presenter.presentFetchDetails(response: .error)
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

    func fetchReview(request: MovieDetailsModels.FetchReview.Request) {
        Task {
            let reviewText: String?
            do {
                reviewText = try await activityRepository.fetchReview(for: request.movieId)
            } catch {
                reviewText = nil
            }
            await MainActor.run {
                presenter.presentReview(
                    response: .init(reviewText: reviewText)
                )
            }
        }
    }

    func updateActivity(request: MovieDetailsModels.UpdateActivity.Request) {
        Task {
            do {
                let activity: MovieActivity
                switch request.action {
                case let .rate(rating, reviewText):
                    activity = try await activityRepository.rateMovie(
                        for: request.movieId,
                        rating: rating
                    )
                    try await activityRepository.saveReview(
                        for: request.movieId,
                        rating: rating,
                        text: reviewText ?? ""
                    )
                case let .favorite(isFavorite):
                    activity = try await activityRepository.setFavorite(
                        isFavorite,
                        for: request.movieId
                    )
                case let .watchlist(isInWatchlist):
                    activity = try await activityRepository.setWatchlist(
                        isInWatchlist,
                        for: request.movieId
                    )
                }
                await MainActor.run {
                    presenter.presentUpdateActivity(response: .content(activity))
                }
            } catch {
                await MainActor.run {
                    presenter.presentUpdateActivity(response: .error)
                }
            }
        }
    }

    private static func makeActivityMetadata(from movie: MovieDetails) -> MovieActivityMetadata {
        MovieActivityMetadata(
            movieId: movie.id,
            title: movie.title,
            posterURL: movie.posterURL,
            backdropURL: movie.backdropURL,
            runtimeMinutes: movie.runtime,
            releaseYear: movie.releaseYear,
            genres: movie.genres,
            directorNames: movie.crew
                .filter { $0.job == "Director" }
                .map(\.name),
            actorNames: movie.cast.map(\.name)
        )
    }

    private static func makeEmptyActivity(
        metadata: MovieActivityMetadata
    ) -> MovieActivity {
        MovieActivity(
            metadata: metadata,
            rating: nil,
            ratedAt: nil,
            isFavorite: false,
            isInWatchlist: false,
            updatedAt: Date()
        )
    }
}
