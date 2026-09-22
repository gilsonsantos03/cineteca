import UIKit

protocol EditProfileDisplayLogic: AnyObject {
    func displayFetchProfile(viewModel: EditProfileModels.FetchProfile.ViewModel)
    func displaySaveProfile(viewModel: EditProfileModels.SaveProfile.ViewModel)
    func displayLoading()
}

final class EditProfileViewController: UIViewController {
    private let customView: EditProfileView
    private let interactor: EditProfileBusinessLogic
    private let router: EditProfileRoutingLogic

    init(
        customView: EditProfileView,
        interactor: EditProfileBusinessLogic,
        router: EditProfileRoutingLogic
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
        interactor.fetchProfile(request: .init())
    }
}

// MARK: - EditProfileDisplayLogic

extension EditProfileViewController: EditProfileDisplayLogic {
    func displayLoading() {
        customView.showLoading()
    }

    func displayFetchProfile(viewModel: EditProfileModels.FetchProfile.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        case .error:
            customView.showError()
        }
    }

    func displaySaveProfile(viewModel: EditProfileModels.SaveProfile.ViewModel) {
        switch viewModel {
        case .success:
            router.routeBack()
        case .error:
            customView.showSaveError()
        }
    }
}

// MARK: - EditProfileViewDelegate

extension EditProfileViewController: EditProfileViewDelegate {
    func didTapBack() {
        router.routeBack()
    }

    func didTapCancel() {
        router.routeBack()
    }

    func didTapSave(displayName: String, bio: String) {
        customView.setSaving(true)
        interactor.saveProfile(request: .init(displayName: displayName, bio: bio))
    }

    func didTapChangePhoto() {}
}
