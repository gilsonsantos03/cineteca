import UIKit

protocol HomeDisplayLogic: AnyObject {
    func displayFetchContent(viewModel: HomeModels.FetchContent.ViewModel)
    func displayLoading()
    func displayWatchTrailer(viewModel: HomeModels.WatchTrailer.ViewModel)
    func displayDidTapWatchlist(viewModel: HomeModels.DidTapWatchlist.ViewModel)
}

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

    func displayDidTapWatchlist(viewModel: HomeModels.DidTapWatchlist.ViewModel) {
        switch viewModel {
        case let .success(isInWatchlist):
            customView.updateWatchlist(isInWatchlist: isInWatchlist)
        case .error:
            let alert = UIAlertController(
                title: Strings.MovieDetailsScene.ActivityError.title,
                message: Strings.MovieDetailsScene.ActivityError.message,
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(
                    title: Strings.MovieDetailsScene.ActivityError.okButton,
                    style: .default
                )
            )
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

    func didTapWatchlist(movieId: Int, isInWatchlist: Bool) {
        interactor.didTapWatchlist(
            request: .init(movieId: movieId, isInWatchlist: isInWatchlist)
        )
    }

    func didSelectMovie(id movieId: Int) {
        router.routeToMovieDetails(movieId: movieId)
    }

    func didTapSeeAll(category: MovieCollectionCategory, title: String) {
        router.routeToMovieCatalog(category: category, title: title)
    }
}
