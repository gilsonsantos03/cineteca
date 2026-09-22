import UIKit

protocol StatsDisplayLogic: AnyObject {
    func displayFetchStats(viewModel: StatsModels.FetchStats.ViewModel)
    func displayLoading()
}

final class StatsViewController: UIViewController {
    private let customView: StatsView
    private let interactor: StatsBusinessLogic

    init(customView: StatsView, interactor: StatsBusinessLogic) {
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor.fetchStats(request: .init())
    }
}

extension StatsViewController: StatsDisplayLogic {
    func displayFetchStats(viewModel: StatsModels.FetchStats.ViewModel) {
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
