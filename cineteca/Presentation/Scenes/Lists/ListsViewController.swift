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

    init(
        customView: ListsView,
        interactor: ListsBusinessLogic,
        router: ListsRoutingLogic
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
        interactor.fetchContent(request: .init())
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
        interactor.selectList(request: .init(list: list))
    }

    func didSelectMovie(id movieId: Int) {
        router.routeToMovieDetails(movieId: movieId)
    }

    func didRequestRemoveMovie(id movieId: Int) {
        interactor.removeMovie(request: .init(movieId: movieId))
    }

    func didRequestRetry() {
        interactor.fetchContent(request: .init())
    }
}
