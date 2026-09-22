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
