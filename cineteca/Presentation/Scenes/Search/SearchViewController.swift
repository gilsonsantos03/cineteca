import UIKit

protocol SearchDisplayLogic: AnyObject {
    func displayMovies(viewModel: SearchModels.Movies.ViewModel)
    func displayLoading(viewModel: SearchModels.Loading.ViewModel)
    func displayFilters(viewModel: SearchModels.ShowFilters.ViewModel)
}

protocol SearchSelectionDelegate: AnyObject {
    func didSelectMovie(movieId: Int, title: String, backdropURL: URL?)
}

final class SearchViewController: UIViewController {
    // MARK: - Properties

    weak var selectionDelegate: SearchSelectionDelegate?

    private let customView: SearchView
    private let interactor: SearchBusinessLogic
    private let router: SearchRoutingLogic
    private let selectionBehavior: SearchModels.SelectionBehavior

    private var debounceTask: Task<Void, Never>?
    private var currentMovies: [SearchModels.MovieGridViewModel] = []
    private var filtersViewController: SearchFiltersViewController?

    init(
        customView: SearchView,
        interactor: SearchBusinessLogic,
        router: SearchRoutingLogic,
        selectionBehavior: SearchModels.SelectionBehavior
    ) {
        self.customView = customView
        self.interactor = interactor
        self.router = router
        self.selectionBehavior = selectionBehavior
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        customView.delegate = self
        interactor.loadContent(request: .init())
    }
}

extension SearchViewController: SearchDisplayLogic {
    func displayMovies(viewModel: SearchModels.Movies.ViewModel) {
        switch viewModel {
        case let .content(movies, mode):
            currentMovies = movies
            customView.showMovies(movies: movies, mode: mode)
        case .error:
            customView.showError()
        }
    }

    func displayLoading(viewModel: SearchModels.Loading.ViewModel) {
        customView.showLoading(mode: viewModel.mode)
    }

    func displayFilters(viewModel: SearchModels.ShowFilters.ViewModel) {
        let filtersVC = SearchFiltersViewController()
        filtersVC.delegate = self
        filtersVC.configure(viewModel: viewModel.filters)

        if let sheet = filtersVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 20
        }

        filtersViewController = filtersVC
        present(filtersVC, animated: true)
    }
}

// MARK: - SearchViewDelegate

extension SearchViewController: SearchViewDelegate {
    func didChangeQuery(_ query: String) {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                interactor.search(request: .init(query: query))
            }
        }
    }

    func didSubmitQuery(_ query: String) {
        debounceTask?.cancel()
        interactor.search(request: .init(query: query))
    }

    func didTapFilter() {
        interactor.showFilters()
    }

    func didSelectMovie(at index: Int) {
        guard currentMovies.indices.contains(index) else { return }
        let movie = currentMovies[index]

        switch selectionBehavior {
        case .openDetails:
            router.routeToMovieDetails(movieId: movie.id)
        case .selectMovie:
            guard let selectionDelegate else { return }
            selectionDelegate.didSelectMovie(
                movieId: movie.id,
                title: movie.title,
                backdropURL: movie.backdropURL
            )
            dismiss(animated: true)
        }
    }

    func didRequestRetry() {
        interactor.loadContent(request: .init())
    }
}

// MARK: - SearchFiltersViewControllerDelegate

extension SearchViewController: SearchFiltersViewControllerDelegate {
    func didUpdateFilters(_ filters: SearchFilters) {
        interactor.updateFilters(request: .init(filters: filters))
    }
}

// MARK: - Navigation

private extension SearchViewController {
    func configureNavigationBar() {
        switch selectionBehavior {
        case .openDetails:
            navigationController?.setNavigationBarHidden(true, animated: false)
        case .selectMovie:
            navigationController?.setNavigationBarHidden(false, animated: false)
            navigationItem.title = Strings.SearchScene.selectionTitle
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(didTapClose)
            )
        }
    }

    @objc func didTapClose() {
        dismiss(animated: true)
    }
}
