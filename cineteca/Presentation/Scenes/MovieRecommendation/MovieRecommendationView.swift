import UIKit
import Cartography

protocol MovieRecommendationViewDelegate: AnyObject {
    func didRequestRecommendation(mode: MovieRecommendationMode)
    func didRequestBack()
    func didRequestMovieSelection(at index: Int)
    func didRemoveMovie(at index: Int)
    func didSelectRecommendedMovie()
    func didRequestRetry()
    func didRequestNewRecommendation()
}

final class MovieRecommendationView: UIView {

    // MARK: - Properties

    weak var delegate: MovieRecommendationViewDelegate?

    private enum State: Equatable {
        case input
        case loading
        case result
        case error
    }

    // MARK: - UI Components

    private lazy var navigationHeader = BackNavigationHeaderView(title: Strings.MovieRecommendationScene.title)

    private lazy var recommendationInputView: MovieRecommendationInputView = {
        let view = MovieRecommendationInputView()
        view.delegate = self
        return view
    }()

    private lazy var resultView: MovieRecommendationResultView = {
        let view = MovieRecommendationResultView()
        view.delegate = self
        return view
    }()

    private lazy var errorView: MovieRecommendationErrorView = {
        let view = MovieRecommendationErrorView()
        view.delegate = self
        return view
    }()

    private lazy var newRecommendationButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = Strings.MovieRecommendationScene.newRecommendation
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 8,
            bottom: 10,
            trailing: 8
        )
        configuration.baseForegroundColor = .accentYellow

        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(newRecommendationTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "movieRecommendation.newRecommendationButton"
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return button
    }()

    private lazy var loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .accentYellow
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            recommendationInputView,
            resultView,
            errorView,
            newRecommendationButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        navigationHeader.delegate = self
        setupSubviews()
        setupConstraints()
        setState(.input)
    }

    private func setupSubviews() {
        addSubview(navigationHeader)
        addSubview(scrollView)
        scrollView.addSubview(contentStack)
        addSubview(loader)
    }

    private func setupConstraints() {
        constrainNavigationHeader()
        constrainScrollView()
        constrainContentStack()
        constrainLoader()
    }

    private func constrainNavigationHeader() {
        constrain(navigationHeader, self) { header, superview in
            header.top == superview.safeAreaLayoutGuide.top + 12
            header.leading == superview.leading
            header.trailing == superview.trailing
            header.height == 36
        }
    }

    private func constrainScrollView() {
        constrain(scrollView, navigationHeader, self) { scrollView, header, superview in
            scrollView.top == header.bottom + 16
            scrollView.leading == superview.leading
            scrollView.trailing == superview.trailing
            scrollView.bottom == superview.safeAreaLayoutGuide.bottom
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView) { stack, scrollView in
            stack.top == scrollView.top + 8
            stack.leading == scrollView.leading + 20
            stack.trailing == scrollView.trailing - 20
            stack.bottom == scrollView.bottom - 24
            stack.width == scrollView.width - 40
        }
    }

    private func constrainLoader() {
        constrain(loader, self) { loader, superview in
            loader.center == superview.center
        }
    }

    // MARK: - Public API

    func displayLoading() {
        setState(.loading)
    }

    func displayResult(_ viewModel: MovieRecommendationModels.Generate.ResultViewModel) {
        resultView.configure(viewModel: viewModel)
        setState(.result)
    }

    func displayError(_ message: String) {
        errorView.configure(message: message)
        setState(.error)
    }

    func updateSelectedMovies(_ movies: [MovieRecommendationModels.SelectedMovieViewModel]) {
        recommendationInputView.updateSelectedMovies(movies)
    }

    func resetForNewRecommendation() {
        recommendationInputView.reset()
        setState(.input)
    }

    // MARK: - Helpers

    private func setState(_ state: State) {
        let isLoading = state == .loading
        scrollView.isHidden = isLoading
        loader.isHidden = !isLoading

        if isLoading {
            loader.startAnimating()
        } else {
            loader.stopAnimating()
        }

        recommendationInputView.isHidden = state != .input
        resultView.isHidden = state != .result
        errorView.isHidden = state != .error
        newRecommendationButton.isHidden = state != .result
    }

    // MARK: - Actions

    @objc private func newRecommendationTapped() {
        delegate?.didRequestNewRecommendation()
    }
}

// MARK: - BackNavigationHeaderViewDelegate

extension MovieRecommendationView: BackNavigationHeaderViewDelegate {
    func didTapBack() {
        delegate?.didRequestBack()
    }
}

// MARK: - MovieRecommendationInputViewDelegate

extension MovieRecommendationView: MovieRecommendationInputViewDelegate {
    func didRequestRecommendation(mode: MovieRecommendationMode) {
        delegate?.didRequestRecommendation(mode: mode)
    }

    func didRequestMovieSelection(at index: Int) {
        delegate?.didRequestMovieSelection(at: index)
    }

    func didRemoveMovie(at index: Int) {
        delegate?.didRemoveMovie(at: index)
    }
}

// MARK: - MovieRecommendationResultViewDelegate

extension MovieRecommendationView: MovieRecommendationResultViewDelegate {
    func didSelectRecommendedMovie() {
        delegate?.didSelectRecommendedMovie()
    }
}

// MARK: - MovieRecommendationErrorViewDelegate

extension MovieRecommendationView: MovieRecommendationErrorViewDelegate {
    func didRequestRetry() {
        delegate?.didRequestRetry()
    }

    func didRequestNewRecommendation() {
        delegate?.didRequestNewRecommendation()
    }
}

