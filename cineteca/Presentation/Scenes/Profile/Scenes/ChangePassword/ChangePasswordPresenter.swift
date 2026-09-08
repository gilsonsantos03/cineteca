import Foundation

protocol ChangePasswordPresentationLogic {
    func presentUpdatePassword(response: ChangePasswordModels.UpdatePassword.Response)
}

protocol ChangePasswordDisplayLogic: AnyObject {
    func displayUpdatePassword(viewModel: ChangePasswordModels.UpdatePassword.ViewModel)
}

final class ChangePasswordPresenter {
    weak var view: ChangePasswordDisplayLogic?
}

extension ChangePasswordPresenter: ChangePasswordPresentationLogic {
    func presentUpdatePassword(response: ChangePasswordModels.UpdatePassword.Response) {
        switch response {
        case .success:
            view?.displayUpdatePassword(viewModel: .success)
        case .invalidCurrentPassword:
            view?.displayUpdatePassword(viewModel: .invalidCurrentPassword)
        case .passwordTooShort:
            view?.displayUpdatePassword(viewModel: .passwordTooShort)
        case .passwordMismatch:
            view?.displayUpdatePassword(viewModel: .passwordMismatch)
        case .error:
            view?.displayUpdatePassword(viewModel: .error)
        }
    }
}
