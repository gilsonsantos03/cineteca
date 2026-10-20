import Foundation

protocol MovieDetailsPresentationLogic {
    func presentLoading()
    func presentFetchDetails(response: MovieDetailsModels.FetchDetails.Response)
    func presentWatchTrailer(response: MovieDetailsModels.WatchTrailer.Response)
    func presentReview(response: MovieDetailsModels.FetchReview.Response)
    func presentUpdateActivity(response: MovieDetailsModels.UpdateActivity.Response)
}

final class MovieDetailsPresenter {
    weak var view: MovieDetailsDisplayLogic?
}

extension MovieDetailsPresenter: MovieDetailsPresentationLogic {
    func presentLoading() {
        view?.displayLoading()
    }

    func presentFetchDetails(response: MovieDetailsModels.FetchDetails.Response) {
        guard case let .content(movie, activity) = response else {
            view?.displayFetchDetails(
                viewModel: .error(
                    .init(
                        title: Strings.MovieDetailsScene.Error.title,
                        message: Strings.MovieDetailsScene.Error.message
                    )
                )
            )
            return
        }

        let metadata = [movie.releaseYear, formatRuntime(movie.runtime)]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " • ")

        let content = MovieDetailsModels.FetchDetails.ViewModel.Content(
            movieId: movie.id,
            title: movie.title,
            overview: movie.overview,
            posterURL: movie.posterURL,
            backdropURL: movie.backdropURL,
            metadata: metadata,
            certification: formatCertification(movie.certification),
            genres: Array(movie.genres.prefix(3)).map(\.name),
            rating: String(format: "%.1f", movie.rating),
            cast: movie.cast.map { makeCastViewModel(from: $0) },
            crew: movie.crew.map { makeCrewViewModel(from: $0) },
            watchProviderGroups: movie.watchProviders.groups.map { makeWatchProviderGroupViewModel(from: $0) },
            watchOptionsURL: movie.watchProviders.optionsURL,
            similarMovies: movie.similarMovies.prefix(10).map { makeSimilarMovieViewModel(from: $0) },
            activity: makeActivityViewModel(from: activity)
        )
        view?.displayFetchDetails(viewModel: .content(content))
    }

    func presentWatchTrailer(response: MovieDetailsModels.WatchTrailer.Response) {
        switch response {
        case let .success(youtubeKey):
            view?.displayWatchTrailer(viewModel: .success(youtubeKey: youtubeKey))
        case .unavailable:
            view?.displayWatchTrailer(
                viewModel: .unavailable(
                    title: Strings.MovieDetailsScene.TrailerUnavailable.title,
                    message: Strings.MovieDetailsScene.TrailerUnavailable.message
                )
            )
        }
    }

    func presentReview(response: MovieDetailsModels.FetchReview.Response) {
        view?.displayReview(
            viewModel: .init(reviewText: response.reviewText)
        )
    }

    func presentUpdateActivity(response: MovieDetailsModels.UpdateActivity.Response) {
        switch response {
        case let .content(activity):
            view?.displayActivity(viewModel: makeActivityViewModel(from: activity))
        case .error:
            view?.displayActivityError()
        }
    }

    private func makeActivityViewModel(from activity: MovieActivity) -> MovieDetailsModels.ActivityViewModel {
        MovieDetailsModels.ActivityViewModel(
            rating: activity.rating,
            isFavorite: activity.isFavorite,
            isInWatchlist: activity.isInWatchlist,
            canFavorite: activity.isRated
        )
    }

    private func makeCastViewModel(from member: MovieCastMember) -> MovieDetailsModels.CastViewModel {
        MovieDetailsModels.CastViewModel(
            name: member.name,
            character: member.character,
            profileURL: member.profileURL
        )
    }

    private func makeCrewViewModel(from member: MovieCrewMember) -> MovieDetailsModels.CrewViewModel {
        MovieDetailsModels.CrewViewModel(
            name: member.name,
            role: Strings.MovieDetailsScene.Crew.job(member.job)
        )
    }

    private func makeWatchProviderGroupViewModel(
        from group: MovieWatchProviderGroup
    ) -> MovieDetailsModels.WatchProviderGroupViewModel {
        MovieDetailsModels.WatchProviderGroupViewModel(
            title: Strings.MovieDetailsScene.ProviderCategory.title(group.category),
            providers: group.providers.map {
                MovieDetailsModels.WatchProviderViewModel(name: $0.name, logoURL: $0.logoURL)
            }
        )
    }

    private func makeSimilarMovieViewModel(from movie: Movie) -> MovieDetailsModels.SimilarMovieViewModel {
        MovieDetailsModels.SimilarMovieViewModel(id: movie.id, title: movie.title, posterURL: movie.posterURL)
    }

    private func formatRuntime(_ runtime: Int?) -> String? {
        guard let runtime else { return nil }
        return runtime >= 60
            ? "\(runtime / 60)h \(runtime % 60)m"
            : "\(runtime)m"
    }

    private func formatCertification(_ certification: String?) -> String? {
        guard let certification, !certification.isEmpty else { return nil }
        if certification.allSatisfy(\.isNumber) {
            return Strings.MovieDetailsScene.Certification.age(certification)
        }
        return certification
    }
}
