import Foundation

final class AuthenticationPresenter: AuthenticationPresentationLogic {
    weak var view: AuthenticationDisplayLogic?

    func presentSubmit(response: AuthenticationModels.Submit.Response) {
        switch response {
        case .success:
            view?.displaySubmit(viewModel: .success)
        case let .error(error):
            view?.displaySubmit(
                viewModel: .error(message(for: error))
            )
        }
    }

    func presentPasswordReset(response: AuthenticationModels.PasswordReset.Response) {
        switch response {
        case .success:
            view?.displayPasswordReset(viewModel: .success)
        case let .error(error):
            view?.displayPasswordReset(
                viewModel: .error(message(for: error))
            )
        }
    }

    private func message(for error: Error) -> String {
        if let profileError = error as? UserProfileError {
            switch profileError {
            case .invalidUsername:
                return Strings.AuthenticationScene.invalidUsername
            case .usernameTaken:
                return Strings.AuthenticationScene.usernameTaken
            }
        }

        guard let authenticationError = error as? AuthenticationError else {
            return error.localizedDescription
        }

        switch authenticationError {
        case .invalidCredential:
            return Strings.AuthenticationScene.invalidCredential
        case .invalidCredentials:
            return Strings.AuthenticationScene.invalidCredentials
        case .invalidEmail:
            return Strings.AuthenticationScene.invalidEmail
        case .weakPassword:
            return Strings.AuthenticationScene.weakPassword
        case .emailAlreadyInUse:
            return Strings.AuthenticationScene.emailAlreadyInUse
        case .passwordMismatch:
            return Strings.AuthenticationScene.passwordMismatch
        case .networkError:
            return Strings.AuthenticationScene.networkError
        case .tooManyRequests:
            return Strings.AuthenticationScene.tooManyRequests
        case .userDisabled:
            return Strings.AuthenticationScene.userDisabled
        case .operationNotAllowed:
            return Strings.AuthenticationScene.operationNotAllowed
        case .unavailable:
            return Strings.AuthenticationScene.unavailable
        case .notConfigured:
            return Strings.AuthenticationScene.notConfigured
        case .userNotAuthenticated:
            return Strings.AuthenticationScene.userNotAuthenticated
        case .deletionRequiresRecentLogin:
            return Strings.AuthenticationScene.deletionRequiresRecentLogin
        case .cancelled:
            return error.localizedDescription
        case let .underlying(message):
            return message
        }
    }
}
