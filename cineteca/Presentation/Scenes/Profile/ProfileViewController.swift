import UIKit

final class ProfileViewController: UIViewController {
    private let customView: ProfileView
    private let interactor: ProfileBusinessLogic
    private let router: ProfileRoutingLogic

    init(
        customView: ProfileView,
        interactor: ProfileBusinessLogic,
        router: ProfileRoutingLogic
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor.fetchProfile(request: .init())
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
        router.routeToEditProfile()
    }
}
