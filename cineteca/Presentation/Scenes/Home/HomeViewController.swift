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
        customView.delegate = self
        interactor.fetchContent(request: .init())
    }
}

extension HomeViewController: HomeDisplayLogic {
    func displayFetchContent(viewModel: HomeModels.FetchContent.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        case .error:
            customView.showError()
        }
        customView.endRefreshing()
    }

    func displayLoading() {
        customView.showLoading()
    }

    func displayWatchTrailer(viewModel: HomeModels.WatchTrailer.ViewModel) {
        switch viewModel {
        case let .success(youtubeKey):
            router.routeToTrailer(youtubeKey: youtubeKey)
        case let .unavailable(title, message):
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Strings.HomeScene.TrailerUnavailable.okButton, style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - HomeViewDelegate

extension HomeViewController: HomeViewDelegate {
    func didRequestRefresh() {
        interactor.refresh()
    }

    func didRequestRetry() {
        interactor.fetchContent(request: .init())
    }

    func didSelectGenre(at index: Int) {
        interactor.selectGenre(request: .init(index: index))
    }

    func didRequestWatchTrailer(movieId: Int) {
        interactor.watchTrailer(request: .init(movieId: movieId))
    }

    func didSelectMovie(id movieId: Int) {
        router.routeToMovieDetails(movieId: movieId)
    }
}
