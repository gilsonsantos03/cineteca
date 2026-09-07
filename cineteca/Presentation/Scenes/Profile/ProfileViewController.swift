import UIKit

final class ProfileViewController: UIViewController {
    private let customView: ProfileView
    private let interactor: ProfileBusinessLogic

    init(customView: ProfileView, interactor: ProfileBusinessLogic) {
        self.customView = customView
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
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
