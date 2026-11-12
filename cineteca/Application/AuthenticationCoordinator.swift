import UIKit

@MainActor
final class AuthenticationCoordinator: NSObject, AuthenticationGateProtocol {
    private let authRepository: AuthRepositoryProtocol
    private let providers: [AuthenticationProviderProtocol]
    private let presenterProvider: () -> UIViewController?

    private weak var authenticationViewController: AuthenticationViewController?
    private var pendingAction: (@MainActor () -> Void)?

    init(
        authRepository: AuthRepositoryProtocol,
        providers: [AuthenticationProviderProtocol],
        presenterProvider: @escaping () -> UIViewController?
    ) {
        self.authRepository = authRepository
        self.providers = providers
        self.presenterProvider = presenterProvider
    }

    var isAuthenticated: Bool {
        if case .authenticated = authRepository.state {
            return true
        }
        return false
    }

    func performAuthenticated(_ action: @escaping @MainActor () -> Void) {
        guard !isAuthenticated else {
            action()
            return
        }

        pendingAction = action
        presentAuthenticationIfNeeded()
    }

    func requestAuthentication() {
        performAuthenticated {}
    }

    private func presentAuthenticationIfNeeded() {
        guard authenticationViewController == nil else { return }
        guard let presenter = presenterProvider() else { return }

        let viewModelProviders = providers.map {
            AuthenticationModels.ProviderViewModel(
                identifier: $0.identifier,
                title: title(for: $0.identifier)
            )
        }
        let viewController = AuthenticationConfigurator.resolve(
            authRepository: authRepository,
            providers: providers,
            providerViewModels: viewModelProviders
        )
        viewController.delegate = self
        viewController.modalPresentationStyle = .pageSheet
        presenter.present(viewController, animated: true)
        authenticationViewController = viewController
    }

    private func title(for _: String) -> String {
        Strings.AuthenticationScene.signIn
    }

    private func completeAuthentication() {
        let action = pendingAction
        pendingAction = nil
        authenticationViewController?.dismiss(animated: true)
        authenticationViewController = nil
        action?()
    }
}

extension AuthenticationCoordinator: AuthenticationViewControllerDelegate {
    func didCompleteAuthentication() {
        completeAuthentication()
    }

    func didCancelAuthentication() {
        pendingAction = nil
        authenticationViewController?.dismiss(animated: true)
        authenticationViewController = nil
    }
}
