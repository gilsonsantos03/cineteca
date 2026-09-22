import Foundation

protocol MovieDetailsPresentationLogic {
    func presentLoading()
    func presentDetails(response: MovieDetailsModels.FetchDetails.Response)
    func presentError(_ error: Error)
    func presentWatchTrailer(response: MovieDetailsModels.WatchTrailer.Response)
}

final class MovieDetailsPresenter {
    weak var view: MovieDetailsDisplayLogic?
}

extension MovieDetailsPresenter: MovieDetailsPresentationLogic {
    func presentLoading() {
        view?.displayLoading()
    }

    func presentDetails(response: MovieDetailsModels.FetchDetails.Response) {
        let movie = response.movie
        let metadata = [movie.releaseYear, formatRuntime(movie.runtime)]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " • ")

        let viewModel = MovieDetailsModels.FetchDetails.ViewModel(
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
            watchProviders: movie.watchProviders.map { makeWatchProviderViewModel(from: $0) },
            similarMovies: movie.similarMovies.prefix(10).map { makeSimilarMovieViewModel(from: $0) }
        )
        view?.displayDetails(viewModel: viewModel)
    }

    func presentError(_ error: Error) {
        let viewModel = MovieDetailsModels.ErrorState.ViewModel(
            title: Strings.MovieDetailsScene.Error.title,
            message: Strings.MovieDetailsScene.Error.message
        )
        view?.displayError(viewModel: viewModel)
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

    private func makeWatchProviderViewModel(from provider: WatchProvider) -> MovieDetailsModels.WatchProviderViewModel {
        MovieDetailsModels.WatchProviderViewModel(name: provider.name, logoURL: provider.logoURL)
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
