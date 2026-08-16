import UIKit
import Cartography

protocol SearchViewDelegate: AnyObject {
    func didChangeQuery(_ query: String)
    func didSubmitQuery(_ query: String)
    func didTapFilter()
    func didSelectMovie(at index: Int)
    func didRequestRetry()
}

final class SearchView: UIView {

    // MARK: - Properties

    weak var delegate: SearchViewDelegate?

    // MARK: - UI Components

    private lazy var searchBarView = SearchBarView()
    private lazy var searchContentView = SearchContentView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        searchBarView.delegate = self
        searchContentView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(searchBarView)
        addSubview(searchContentView)
    }

    private func setupConstraints() {
        constrainSearchBarView()
        constrainSearchContentView()
    }

    private func constrainSearchBarView() {
        constrain(searchBarView, self) { bar, superview in
            bar.top == superview.safeAreaLayoutGuide.top
            bar.left == superview.left
            bar.right == superview.right
        }
    }

    private func constrainSearchContentView() {
        constrain(searchContentView, searchBarView, self) { content, bar, superview in
            content.top == bar.bottom
            content.left == superview.left
            content.right == superview.right
            content.bottom == superview.bottom
        }
    }

    // MARK: - Public API

    func showLoading(mode: SearchDisplayMode) {
        searchContentView.showLoading(mode: mode)
    }

    func showMovies(movies: [SearchMovieGridViewModel], mode: SearchDisplayMode) {
        searchContentView.showMovies(movies: movies, mode: mode)
    }

    func showError() {
        searchContentView.showError()
    }
}

// MARK: - SearchBarViewDelegate

extension SearchView: SearchBarViewDelegate {
    func didChangeText(_ text: String) {
        delegate?.didChangeQuery(text)
    }

    func didSubmitQuery(_ query: String) {
        delegate?.didSubmitQuery(query)
    }

    func didTapFilter() {
        delegate?.didTapFilter()
    }
}

// MARK: - SearchContentViewDelegate

extension SearchView: SearchContentViewDelegate {
    func didSelectMovie(at index: Int) {
        delegate?.didSelectMovie(at: index)
    }

    func didRequestRetry() {
        delegate?.didRequestRetry()
    }
}
