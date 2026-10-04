import UIKit

protocol LegalDisplayLogic: AnyObject {
    func displayFetchLegal(viewModel: LegalModels.FetchLegal.ViewModel)
}

final class LegalViewController: UIViewController {
    private let customView: LegalView
    private let interactor: LegalBusinessLogic
    private let router: LegalRoutingLogic

    init(
        customView: LegalView,
        interactor: LegalBusinessLogic,
        router: LegalRoutingLogic
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
        interactor.fetchLegal(request: .init())
    }
}

extension LegalViewController: LegalDisplayLogic {
    func displayFetchLegal(viewModel: LegalModels.FetchLegal.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        }
    }
}

extension LegalViewController: LegalViewDelegate {
    func didTapBack() {
        router.routeBack()
    }

    func didSelectLink(_ action: LegalModels.LinkAction) {
        switch action {
        case .privacyPolicy:
            router.routeToPrivacyPolicy()
        case .termsOfService:
            router.routeToTermsOfService()
        }
    }
}
