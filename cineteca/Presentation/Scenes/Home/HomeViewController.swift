import UIKit

final class HomeViewController: UIViewController {
    private let customView: HomeView
    private let interactor: HomeBusinessLogic
    private let router: HomeRoutingLogic

    init(customView: HomeView, interactor: HomeBusinessLogic, router: HomeRoutingLogic) {
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
        customView.onRefresh = { [weak self] in self?.interactor.refresh() }
        customView.onRetry = { [weak self] in self?.interactor.fetchContent(request: .init()) }
        interactor.fetchContent(request: .init())
    }
}

extension HomeViewController: HomeDisplayLogic {
    func displayContent(viewModel: HomeModels.FetchContent.ViewModel) {
        customView.showContent(viewModel: viewModel)
        customView.endRefreshing()
    }

    func displayLoading() {
        customView.showLoading()
    }

    func displayError(viewModel: HomeModels.ErrorState.ViewModel) {
        customView.showError()
        customView.endRefreshing()
    }
}
