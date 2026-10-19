import UIKit

protocol StatsDisplayLogic: AnyObject {
    func displayFetchStats(viewModel: StatsModels.FetchStats.ViewModel)
    func displayLoading()
}

final class StatsViewController: UIViewController {
    private let customView: StatsView
    private let interactor: StatsBusinessLogic
    private let authGate: AuthenticationGateProtocol

    init(
        customView: StatsView,
        interactor: StatsBusinessLogic,
        authGate: AuthenticationGateProtocol
    ) {
        self.customView = customView
        self.interactor = interactor
        self.authGate = authGate
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
        if authGate.isAuthenticated {
            interactor.fetchStats(request: .init())
        } else {
            customView.showGuest()
        }
    }
}

extension StatsViewController: StatsViewDelegate {
    func didRequestAuthentication() {
        authGate.performAuthenticated { [weak self] in
            self?.interactor.fetchStats(request: .init())
        }
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
