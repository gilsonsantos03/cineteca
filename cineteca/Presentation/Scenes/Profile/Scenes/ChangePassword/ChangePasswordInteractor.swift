import Foundation

protocol ChangePasswordBusinessLogic {
    func updatePassword(request: ChangePasswordModels.UpdatePassword.Request)
}

final class ChangePasswordInteractor {
    private let presenter: ChangePasswordPresentationLogic
    private let userRepository: UserRepositoryProtocol
    private let minimumPasswordLength = 8

    init(presenter: ChangePasswordPresentationLogic, userRepository: UserRepositoryProtocol) {
        self.presenter = presenter
        self.userRepository = userRepository
    }
}

extension ChangePasswordInteractor: ChangePasswordBusinessLogic {
    func updatePassword(request: ChangePasswordModels.UpdatePassword.Request) {
        let newPassword = request.newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPassword = request.confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        if newPassword.count < minimumPasswordLength {
            presenter.presentUpdatePassword(response: .passwordTooShort)
            return
        }

        if newPassword != confirmPassword {
            presenter.presentUpdatePassword(response: .passwordMismatch)
            return
        }

        Task {
            let response: ChangePasswordModels.UpdatePassword.Response
            do {
                try await userRepository.updatePassword(
                    UserPasswordUpdate(
                        currentPassword: request.currentPassword,
                        newPassword: newPassword
                    )
                )
                response = .success
            } catch UserRepositoryError.invalidCurrentPassword {
                response = .invalidCurrentPassword
            } catch {
                response = .error
            }
            await MainActor.run {
                presenter.presentUpdatePassword(response: response)
            }
        }
    }
}
