import UIKit

protocol SearchFiltersViewControllerDelegate: AnyObject {
    func didUpdateFilters(_ filters: SearchFilters)
}

final class SearchFiltersViewController: UIViewController {
    private let filtersView = SearchFiltersView()

    weak var delegate: SearchFiltersViewControllerDelegate?

    override func loadView() {
        view = filtersView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        filtersView.delegate = self
    }

    func configure(viewModel: SearchFiltersViewModel) {
        filtersView.configure(viewModel: viewModel)
    }
}

extension SearchFiltersViewController: SearchFiltersViewDelegate {
    func didUpdateFilters(_ filters: SearchFilters) {
        delegate?.didUpdateFilters(filters)
    }
}
