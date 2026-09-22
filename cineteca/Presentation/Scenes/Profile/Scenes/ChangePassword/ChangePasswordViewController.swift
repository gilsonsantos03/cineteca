import UIKit

protocol ChangePasswordDisplayLogic: AnyObject {
    func displayUpdatePassword(viewModel: ChangePasswordModels.UpdatePassword.ViewModel)
}

final class ChangePasswordViewController: UIViewController {
    private let customView: ChangePasswordView
    private let interactor: ChangePasswordBusinessLogic
    private let router: ChangePasswordRoutingLogic

    init(
        customView: ChangePasswordView,
        interactor: ChangePasswordBusinessLogic,
        router: ChangePasswordRoutingLogic
    ) {
        self.customView = customView
        self.interactor = interactor
        self.router = router
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
}

extension ChangePasswordViewController: ChangePasswordDisplayLogic {
    func displayUpdatePassword(viewModel: ChangePasswordModels.UpdatePassword.ViewModel) {
        customView.setUpdating(false)

        switch viewModel {
        case .success:
            router.routeBack()
        case .invalidCurrentPassword:
            showAlert(
                title: Strings.ChangePasswordScene.Error.invalidCurrentPasswordTitle,
                message: Strings.ChangePasswordScene.Error.invalidCurrentPasswordMessage
            )
        case .passwordTooShort:
            showAlert(
                title: Strings.ChangePasswordScene.Error.passwordTooShortTitle,
                message: Strings.ChangePasswordScene.Error.passwordTooShortMessage
            )
        case .passwordMismatch:
            showAlert(
                title: Strings.ChangePasswordScene.Error.passwordMismatchTitle,
                message: Strings.ChangePasswordScene.Error.passwordMismatchMessage
            )
        case .error:
            showAlert(
                title: Strings.ChangePasswordScene.Error.genericTitle,
                message: Strings.ChangePasswordScene.Error.genericMessage
            )
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.ChangePasswordScene.Error.okButton, style: .default))
        present(alert, animated: true)
    }
}

extension ChangePasswordViewController: ChangePasswordViewDelegate {
    func didTapBack() {
        router.routeBack()
    }

    func didTapUpdatePassword(currentPassword: String, newPassword: String, confirmPassword: String) {
        customView.setUpdating(true)
        interactor.updatePassword(
            request: .init(
                currentPassword: currentPassword,
                newPassword: newPassword,
                confirmPassword: confirmPassword
            )
        )
    }
}
