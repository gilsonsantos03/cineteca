import Foundation

protocol EditProfilePresentationLogic {
    func presentFetchProfile(response: EditProfileModels.FetchProfile.Response)
    func presentSaveProfile(response: EditProfileModels.SaveProfile.Response)
    func presentLoading()
}

final class EditProfilePresenter {
    weak var view: EditProfileDisplayLogic?
}

extension EditProfilePresenter: EditProfilePresentationLogic {
    func presentFetchProfile(response: EditProfileModels.FetchProfile.Response) {
        switch response {
        case .content(let user):
            view?.displayFetchProfile(viewModel: .content(
                EditProfileModels.FetchProfile.ViewModel.Content(
                    username: user.username,
                    displayName: user.displayName,
                    bio: user.bio,
                    favoriteFilm: user.favoriteFilm.map {
                        EditProfileModels.FavoriteFilmViewModel(
                            movieId: $0.movieId,
                            title: $0.title,
                            backdropURL: $0.backdropURL
                        )
                    },
                    avatarImageName: user.avatarImageName
                )
            ))
        case .error:
            view?.displayFetchProfile(viewModel: .error)
        }
    }

    func presentSaveProfile(response: EditProfileModels.SaveProfile.Response) {
        switch response {
        case .success:
            view?.displaySaveProfile(viewModel: .success)
        case .error:
            view?.displaySaveProfile(viewModel: .error)
        }
    }

    func presentLoading() {
        view?.displayLoading()
    }
}
