import UIKit

protocol ProfileDisplayLogic: AnyObject {
    func displayFetchProfile(viewModel: ProfileModels.FetchProfile.ViewModel)
    func displayLoading()
}

final class ProfileViewController: UIViewController {
    private let customView: ProfileView
    private let interactor: ProfileBusinessLogic
    private let router: ProfileRoutingLogic
    private let authGate: AuthenticationGateProtocol
    private let authRepository: AuthRepositoryProtocol

    init(
        customView: ProfileView,
        interactor: ProfileBusinessLogic,
        router: ProfileRoutingLogic,
        authGate: AuthenticationGateProtocol,
        authRepository: AuthRepositoryProtocol
    ) {
        self.customView = customView
        self.interactor = interactor
        self.router = router
        self.authGate = authGate
        self.authRepository = authRepository
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if authGate.isAuthenticated {
            interactor.fetchProfile(request: .init())
        } else {
            customView.showGuest()
        }
    }
}

extension ProfileViewController: ProfileDisplayLogic {
    func displayFetchProfile(viewModel: ProfileModels.FetchProfile.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        case .error:
            customView.showError()
        }
    }

    func displayLoading() {
        customView.showLoading()
    }
}

extension ProfileViewController: ProfileViewDelegate {
    func didTapEdit() {
        authGate.performAuthenticated { [weak self] in
            self?.router.routeToEditProfile()
        }
    }

    func didTapFavoriteFilm(movieId: Int) {
        router.routeToMovieDetails(movieId: movieId)
    }

    func didTapSeeAllReviews() {
        authGate.performAuthenticated { [weak self] in
            self?.router.routeToMyReviews()
        }
    }

    func didTapSignOut() {
        let alert = UIAlertController(
            title: Strings.AccountScene.Row.logout,
            message: Strings.AccountScene.logoutConfirmation,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: Strings.AccountScene.Row.logout, style: .destructive) { [weak self] _ in
            do {
                try self?.authRepository.signOut()
                self?.customView.showGuest()
            } catch {
                self?.showError(error)
            }
        })
        present(alert, animated: true)
    }

    func didSelectSetting(_ setting: ProfileModels.Setting) {
        switch setting {
        case .account:
            authGate.performAuthenticated { [weak self] in
                self?.router.routeToAccount()
            }
        case .appearance:
            router.routeToAppearance()
        case .language:
            router.routeToLanguage()
        case .legal:
            router.routeToLegal()
        case .notifications:
            break
        }
    }

    func didRequestAuthentication() {
        authGate.performAuthenticated { [weak self] in
            self?.interactor.fetchProfile(request: .init())
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: Strings.Common.error,
            message: (error as? LocalizedError)?.errorDescription ?? error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.Common.ok, style: .default))
        present(alert, animated: true)
    }
}
