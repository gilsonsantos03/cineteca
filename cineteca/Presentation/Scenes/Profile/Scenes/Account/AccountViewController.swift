import UIKit

protocol AccountDisplayLogic: AnyObject {
    func displayFetchAccount(viewModel: AccountModels.FetchAccount.ViewModel)
    func displayLoading()
}

final class AccountViewController: UIViewController {
    private let customView: AccountView
    private let interactor: AccountBusinessLogic
    private let router: AccountRoutingLogic

    init(
        customView: AccountView,
        interactor: AccountBusinessLogic,
        router: AccountRoutingLogic
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
        case .changePassword:
            router.routeToChangePassword()
        case .deleteAccount:
            break
        }
    }
}
