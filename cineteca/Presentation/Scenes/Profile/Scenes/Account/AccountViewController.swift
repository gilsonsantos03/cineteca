import UIKit

protocol AccountDisplayLogic: AnyObject {
    func displayFetchAccount(viewModel: AccountModels.FetchAccount.ViewModel)
    func displayLoading()
}

final class AccountViewController: UIViewController {
    private let customView: AccountView
    private let interactor: AccountBusinessLogic
    private let userRepository: UserRepositoryProtocol
    private let router: AccountRoutingLogic
    private let authRepository: AuthRepositoryProtocol
    private let authGate: AuthenticationGateProtocol

    init(
        customView: AccountView,
        interactor: AccountBusinessLogic,
        userRepository: UserRepositoryProtocol,
        router: AccountRoutingLogic,
        authRepository: AuthRepositoryProtocol,
        authGate: AuthenticationGateProtocol
    ) {
        self.customView = customView
        self.interactor = interactor
        self.userRepository = userRepository
        self.router = router
        self.authRepository = authRepository
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
        interactor.fetchAccount(request: .init())
    }
}

extension AccountViewController: AccountDisplayLogic {
    func displayLoading() {
        customView.showLoading()
    }

    func displayFetchAccount(viewModel: AccountModels.FetchAccount.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        case .error:
            customView.showError()
        }
    }
}

extension AccountViewController: AccountViewDelegate {
    func didTapBack() {
        router.routeBack()
    }

    func didSelectRow(action: AccountModels.RowAction) {
        switch action {
        case .logout:
            confirmLogout()
        case .deleteAccount:
            confirmDeleteAccount()
        }
    }

    private func confirmLogout() {
        let alert = UIAlertController(
            title: Strings.AccountScene.Row.logout,
            message: Strings.AccountScene.logoutConfirmation,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: Strings.AccountScene.Row.logout, style: .destructive) { [weak self] _ in
            do {
                try self?.authRepository.signOut()
                self?.router.routeBack()
            } catch {
                self?.showError(error)
            }
        })
        present(alert, animated: true)
    }

    private func confirmDeleteAccount() {
        let alert = UIAlertController(
            title: Strings.AccountScene.Row.deleteAccount,
            message: Strings.AccountScene.deleteConfirmation,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: Strings.AccountScene.Row.deleteAccount, style: .destructive) { [weak self] _ in
            self?.deleteAccount()
        })
        present(alert, animated: true)
    }

    private func deleteAccount() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await userRepository.deleteCurrentUserData()
                try await authRepository.deleteAccount()
                router.routeBack()
            } catch AuthenticationError.deletionRequiresRecentLogin {
                try? authRepository.signOut()
                authGate.performAuthenticated { [weak self] in
                    self?.deleteAccount()
                }
            } catch {
                showError(error)
            }
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
