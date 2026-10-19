import UIKit

protocol ListsDisplayLogic: AnyObject {
    func displayFetchContent(viewModel: ListsModels.FetchContent.ViewModel)
    func displayRemoveMovie(viewModel: ListsModels.RemoveMovie.ViewModel)
    func displayLoading()
}

final class ListsViewController: UIViewController {
    private let customView: ListsView
    private let interactor: ListsBusinessLogic
    private let router: ListsRoutingLogic
    private let authGate: AuthenticationGateProtocol

    init(
        customView: ListsView,
        interactor: ListsBusinessLogic,
        router: ListsRoutingLogic,
        authGate: AuthenticationGateProtocol
    ) {
        self.customView = customView
        self.interactor = interactor
        self.router = router
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
        loadContentForCurrentSession()
    }
}

extension ListsViewController: ListsDisplayLogic {
    func displayFetchContent(viewModel: ListsModels.FetchContent.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        case .error:
            customView.showError()
        }
    }

    func displayRemoveMovie(viewModel: ListsModels.RemoveMovie.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        case .error:
            let alert = UIAlertController(
                title: Strings.ListsScene.removeErrorTitle,
                message: Strings.ListsScene.removeErrorMessage,
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(title: Strings.ListsScene.okButton, style: .default)
            )
            present(alert, animated: true)
        }
    }

    func displayLoading() {
        customView.showLoading()
    }
}

extension ListsViewController: ListsViewDelegate {
    func didSelectList(_ list: ListsModels.List) {
        guard authGate.isAuthenticated else {
            customView.showGuest(selectedList: list)
            return
        }
        interactor.selectList(request: .init(list: list))
    }

    func didSelectMovie(id movieId: Int) {
        router.routeToMovieDetails(movieId: movieId)
    }

    func didRequestRemoveMovie(id movieId: Int) {
        authGate.performAuthenticated { [weak self] in
            self?.interactor.removeMovie(request: .init(movieId: movieId))
        }
    }

    func didRequestRetry() {
        interactor.fetchContent(request: .init())
    }

    func didRequestAuthentication() {
        authGate.performAuthenticated { [weak self] in
            self?.interactor.fetchContent(request: .init())
        }
    }

    private func loadContentForCurrentSession() {
        if authGate.isAuthenticated {
            interactor.fetchContent(request: .init())
        } else {
            customView.showGuest()
        }
    }
}
