import UIKit

protocol EditProfileDisplayLogic: AnyObject {
    func displayFetchProfile(viewModel: EditProfileModels.FetchProfile.ViewModel)
    func displaySaveProfile(viewModel: EditProfileModels.SaveProfile.ViewModel)
    func displayLoading()
}

final class EditProfileViewController: UIViewController {
    private let customView: EditProfileView
    private let interactor: EditProfileBusinessLogic
    private let router: EditProfileRoutingLogic
    private let authGate: AuthenticationGateProtocol

    init(
        customView: EditProfileView,
        interactor: EditProfileBusinessLogic,
        router: EditProfileRoutingLogic,
        authGate: AuthenticationGateProtocol
    ) {
        self.customView = customView
        self.interactor = interactor
        self.router = router
        self.authGate = authGate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        customView.delegate = self
        interactor.fetchProfile(request: .init())
    }
}

// MARK: - EditProfileDisplayLogic

extension EditProfileViewController: EditProfileDisplayLogic {
    func displayLoading() {
        customView.showLoading()
    }

    func displayFetchProfile(viewModel: EditProfileModels.FetchProfile.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        case .error:
            customView.showError()
        }
    }

    func displaySaveProfile(viewModel: EditProfileModels.SaveProfile.ViewModel) {
        switch viewModel {
        case .success:
            router.routeBack()
        case let .error(error):
            customView.showSaveError()
            let alert = UIAlertController(
                title: Strings.EditProfileScene.errorTitle,
                message: saveErrorMessage(error),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: Strings.Common.ok, style: .default))
            present(alert, animated: true)
        }
    }

}

// MARK: - EditProfileViewDelegate

extension EditProfileViewController: EditProfileViewDelegate {
    func didTapBack() {
        router.routeBack()
    }

    func didTapCancel() {
        router.routeBack()
    }

    func didTapSave(
        username: String,
        displayName: String,
        bio: String,
        favoriteFilm: EditProfileModels.FavoriteFilmViewModel?
    ) {
        authGate.performAuthenticated { [weak self] in
            guard let self else { return }
            self.customView.setSaving(true)
            self.interactor.saveProfile(
                request: .init(
                    username: username,
                    displayName: displayName,
                    bio: bio,
                    favoriteFilm: favoriteFilm
                )
            )
        }
    }

    func didTapChangePhoto() {}

    func didTapChangeFavoriteFilm() {
        router.routeToMovieSearch(delegate: self)
    }

    private func saveErrorMessage(_ error: UserProfileError?) -> String {
        switch error {
        case .invalidUsername:
            return Strings.EditProfileScene.invalidUsername
        case .usernameTaken:
            return Strings.EditProfileScene.usernameTaken
        case nil:
            return Strings.EditProfileScene.errorMessage
        }
    }
}

// MARK: - SearchSelectionDelegate

extension EditProfileViewController: SearchSelectionDelegate {
    func didSelectMovie(movieId: Int, title: String, backdropURL: URL?) {
        customView.setFavoriteFilm(
            EditProfileModels.FavoriteFilmViewModel(
                movieId: movieId,
                title: title,
                backdropURL: backdropURL
            )
        )
    }
}
