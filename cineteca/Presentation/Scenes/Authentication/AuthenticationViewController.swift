import UIKit

@MainActor
protocol AuthenticationViewControllerDelegate: AnyObject {
    func didCompleteAuthentication()
    func didCancelAuthentication()
}

protocol AuthenticationDisplayLogic: AnyObject {
    func displaySubmit(viewModel: AuthenticationModels.Submit.ViewModel)
    func displayPasswordReset(viewModel: AuthenticationModels.PasswordReset.ViewModel)
}

final class AuthenticationViewController: UIViewController {
    weak var delegate: AuthenticationViewControllerDelegate?

    private let customView: AuthenticationView
    private let interactor: AuthenticationBusinessLogic
    private let router: AuthenticationRoutingLogic

    init(
        customView: AuthenticationView,
        interactor: AuthenticationBusinessLogic,
        router: AuthenticationRoutingLogic
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
        customView.delegate = self
        view.accessibilityIdentifier = "authentication.screen"
    }

}

extension AuthenticationViewController: AuthenticationDisplayLogic {
    func displaySubmit(viewModel: AuthenticationModels.Submit.ViewModel) {
        switch viewModel {
        case .success:
            delegate?.didCompleteAuthentication()
        case let .error(message):
            presentAlert(title: Strings.Common.error, message: message)
        }
    }

    func displayPasswordReset(viewModel: AuthenticationModels.PasswordReset.ViewModel) {
        switch viewModel {
        case .success:
            presentAlert(message: Strings.AuthenticationScene.resetSent)
        case let .error(message):
            presentAlert(title: Strings.Common.error, message: message)
        }
    }

    private func presentAlert(title: String? = nil, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.Common.ok, style: .default))
        present(alert, animated: true)
    }
}

extension AuthenticationViewController: AuthenticationViewDelegate {
    func didSubmitEmailPassword(
        email: String,
        username: String,
        password: String,
        mode: AuthenticationModels.Mode,
        confirmation: String
    ) {
        interactor.submit(
            request: .init(
                email: email,
                username: username,
                password: password,
                mode: mode,
                confirmation: confirmation
            )
        )
    }

    func didRequestPasswordReset(email: String) {
        interactor.resetPassword(request: .init(email: email))
    }

    func didSelectProvider(identifier: String) {
        interactor.authenticate(providerIdentifier: identifier)
    }

    func didTapCancelAuthentication() {
        delegate?.didCancelAuthentication()
        router.routeBack()
    }
}
