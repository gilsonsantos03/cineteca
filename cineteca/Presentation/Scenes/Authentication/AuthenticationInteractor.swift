import Foundation

protocol AuthenticationBusinessLogic {
    func submit(request: AuthenticationModels.Submit.Request)
    func resetPassword(request: AuthenticationModels.PasswordReset.Request)
    func authenticate(providerIdentifier: String)
}

protocol AuthenticationPresentationLogic: AnyObject {
    func presentSubmit(response: AuthenticationModels.Submit.Response)
    func presentPasswordReset(response: AuthenticationModels.PasswordReset.Response)
}

final class AuthenticationInteractor {
    private let presenter: AuthenticationPresentationLogic
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let providers: [AuthenticationProviderProtocol]

    init(
        presenter: AuthenticationPresentationLogic,
        authRepository: AuthRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        providers: [AuthenticationProviderProtocol]
    ) {
        self.presenter = presenter
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.providers = providers
    }
}

extension AuthenticationInteractor: AuthenticationBusinessLogic {
    func submit(request: AuthenticationModels.Submit.Request) {
        let email = request.email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty, !request.password.isEmpty else {
            presenter.presentSubmit(response: .error(AuthenticationError.invalidEmail))
            return
        }
        let username: String?
        if request.mode == .signUp {
            do {
                username = try UsernamePolicy.validate(request.username)
            } catch {
                presenter.presentSubmit(response: .error(error))
                return
            }
        } else {
            username = nil
        }
        if request.mode == .signUp, request.password != request.confirmation {
            presenter.presentSubmit(response: .error(AuthenticationError.passwordMismatch))
            return
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                switch request.mode {
                case .signIn:
                    _ = try await authRepository.signIn(
                        email: email,
                        password: request.password
                    )
                case .signUp:
                    _ = try await authRepository.createAccount(
                        email: email,
                        password: request.password
                    )
                    do {
                        _ = try await userRepository.createProfile(username: username ?? "")
                    } catch {
                        try? await userRepository.deleteCurrentUserData()
                        try? await authRepository.deleteAccount()
                        throw error
                    }
                }
                await MainActor.run {
                    self.presenter.presentSubmit(response: .success)
                }
            } catch {
                await MainActor.run {
                    self.presenter.presentSubmit(response: .error(error))
                }
            }
        }
    }

    func resetPassword(request: AuthenticationModels.PasswordReset.Request) {
        let email = request.email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else {
            presenter.presentPasswordReset(response: .error(AuthenticationError.invalidEmail))
            return
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                try await authRepository.sendPasswordReset(to: email)
                await MainActor.run {
                    presenter.presentPasswordReset(response: .success)
                }
            } catch {
                await MainActor.run {
                    presenter.presentPasswordReset(response: .error(error))
                }
            }
        }
    }

    func authenticate(providerIdentifier: String) {
        guard let provider = providers.first(where: { $0.identifier == providerIdentifier }) else {
            return
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                let credential = try await provider.authenticate()
                _ = try await authRepository.signIn(with: credential)
                await MainActor.run {
                    presenter.presentSubmit(response: .success)
                }
            } catch {
                await MainActor.run {
                    presenter.presentSubmit(response: .error(error))
                }
            }
        }
    }
}
