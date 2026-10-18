import UIKit

protocol MovieCatalogDisplayLogic: AnyObject {
    func displayFetchContent(viewModel: MovieCatalogModels.FetchContent.ViewModel)
    func displayFetchNextPage(viewModel: MovieCatalogModels.FetchNextPage.ViewModel)
    func displayLoading()
    func displayLoadingNextPage()
}

final class MovieCatalogViewController: UIViewController {
    private let customView: MovieCatalogView
    private let interactor: MovieCatalogBusinessLogic
    private let router: MovieCatalogRoutingLogic

    init(
        customView: MovieCatalogView,
        interactor: MovieCatalogBusinessLogic,
        router: MovieCatalogRoutingLogic
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
        interactor.fetchContent(request: .init())
    }
}

extension MovieCatalogViewController: MovieCatalogDisplayLogic {
    func displayFetchContent(viewModel: MovieCatalogModels.FetchContent.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        case .error:
            customView.showError()
        }
    }

    func displayFetchNextPage(viewModel: MovieCatalogModels.FetchNextPage.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.appendContent(content: content)
        case .error:
            customView.stopLoadingNextPage()
            showNextPageError()
        }
    }

    func displayLoading() {
        customView.showLoading()
    }

    func displayLoadingNextPage() {
        customView.showLoadingNextPage()
    }
}

// MARK: - MovieCatalogViewDelegate

extension MovieCatalogViewController: MovieCatalogViewDelegate {
    func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    func didSelectMovie(id movieId: Int) {
        router.routeToMovieDetails(movieId: movieId)
    }

    func didRequestRetry() {
        interactor.fetchContent(request: .init())
    }

    func didRequestNextPage() {
        interactor.fetchNextPage(request: .init())
    }

    private func showNextPageError() {
        let alert = UIAlertController(
            title: Strings.MovieCatalogScene.nextPageErrorTitle,
            message: Strings.MovieCatalogScene.nextPageErrorMessage,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: Strings.MovieCatalogScene.okButton,
                style: .default
            )
        )
        present(alert, animated: true)
    }
}
