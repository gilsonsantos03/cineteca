import UIKit
import Cartography

protocol ListsViewDelegate: AnyObject {
    func didSelectList(_ list: ListsModels.List)
    func didSelectMovie(id movieId: Int)
    func didRequestRemoveMovie(id movieId: Int)
    func didRequestRetry()
    func didRequestAuthentication()
}

final class ListsView: UIView {

    // MARK: - Properties

    weak var delegate: ListsViewDelegate?
    private var selectedList: ListsModels.List = .watchlist

    // MARK: - State

    private enum State: Equatable {
        case loading
        case content
        case error
    }

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.ListsScene.title
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var tabsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .appBackground
        return view
    }()

    private lazy var tabsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            watchlistButton,
            favoritesButton,
            ratedButton
        ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var watchlistButton = makeTabButton(
        title: Strings.ListsScene.Tab.watchlist,
        action: #selector(didTapWatchlist)
    )

    private lazy var favoritesButton = makeTabButton(
        title: Strings.ListsScene.Tab.favorites,
        action: #selector(didTapFavorites)
    )

    private lazy var ratedButton = makeTabButton(
        title: Strings.ListsScene.Tab.rated,
        action: #selector(didTapRated)
    )

    private lazy var tabDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    private lazy var selectedTabIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .accentYellow
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .appBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var cardsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        return stack
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cardsStack])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .cardBackground
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        label.heightAnchor.constraint(equalToConstant: 116).isActive = true
        return label
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .accentYellow
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var errorStateView = ListsErrorStateView()
    private lazy var authenticationPromptView = AuthenticationPromptView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        let tabWidth = tabsContainer.bounds.width / CGFloat(ListsModels.List.allCases.count)
        selectedTabIndicatorView.frame = CGRect(
            x: CGFloat(selectedList.rawValue) * tabWidth,
            y: tabsContainer.bounds.height - 2,
            width: tabWidth,
            height: 2
        )
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        errorStateView.delegate = self
        authenticationPromptView.delegate = self
        setupSubviews()
        setupConstraints()
        setState(.loading)
        updateTabs()
    }

    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(tabsContainer)
        tabsContainer.addSubview(tabsStack)
        tabsContainer.addSubview(tabDividerView)
        tabsContainer.addSubview(selectedTabIndicatorView)
        addSubview(scrollView)
        scrollView.addSubview(contentStack)
        addSubview(loadingIndicator)
        addSubview(errorStateView)
        addSubview(authenticationPromptView)
    }

    private func setupConstraints() {
        constrainTitleLabel()
        constrainTabsContainer()
        constrainTabsStack()
        constrainTabDividerView()
        constrainScrollView()
        constrainContentStack()
        constrainLoadingIndicator()
        constrainErrorStateView()
        constrainAuthenticationPromptView()
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, self) { label, superview in
            label.top == superview.safeAreaLayoutGuide.top + 20
            label.left == superview.left + 28
            label.right == superview.right - 28
        }
    }

    private func constrainTabsContainer() {
        constrain(tabsContainer, titleLabel, self) { tabs, title, superview in
            tabs.top == title.bottom + 24
            tabs.left == superview.left + 20
            tabs.right == superview.right - 20
            tabs.height == 44
        }
    }

    private func constrainTabsStack() {
        constrain(tabsStack, tabsContainer) { stack, container in
            stack.edges == container.edges
        }
    }

    private func constrainTabDividerView() {
        constrain(tabDividerView, tabsContainer) { divider, container in
            divider.left == container.left
            divider.right == container.right
            divider.bottom == container.bottom
            divider.height == 1
        }
    }

    private func constrainScrollView() {
        constrain(scrollView, tabsContainer, self) { scroll, tabs, superview in
            scroll.top == tabs.bottom
            scroll.left == superview.left
            scroll.right == superview.right
            scroll.bottom == superview.bottom
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView) { stack, scroll in
            stack.top == scroll.top + 16
            stack.left == scroll.left + 20
            stack.right == scroll.right - 20
            stack.bottom == scroll.bottom - 20
            stack.width == scroll.width - 40
        }
    }

    private func constrainLoadingIndicator() {
        constrain(loadingIndicator, self) { indicator, superview in
            indicator.centerX == superview.centerX
            indicator.centerY == superview.centerY
        }
    }

    private func constrainErrorStateView() {
        constrain(errorStateView, scrollView) { view, scroll in
            view.edges == scroll.edges
            view.width == scroll.width
            view.height == scroll.height
        }
    }

    private func constrainAuthenticationPromptView() {
        constrain(authenticationPromptView, scrollView) { prompt, scroll in
            prompt.centerY == scroll.centerY
            prompt.left == scroll.left + 20
            prompt.right == scroll.right - 20
        }
    }

    // MARK: - Public API

    func showLoading() {
        setState(.loading)
    }

    func showGuest(selectedList: ListsModels.List? = nil) {
        if let selectedList {
            self.selectedList = selectedList
            updateTabs()
        }
        loadingIndicator.stopAnimating()
        scrollView.isHidden = true
        errorStateView.isHidden = true
        authenticationPromptView.isHidden = false
    }

    func showContent(content: ListsModels.FetchContent.ViewModel.Content) {
        selectedList = content.selectedList
        updateTabs()
        configureCards(content.movies)
        setState(.content)
        setNeedsLayout()
    }

    func showError() {
        setState(.error)
    }

    // MARK: - Actions

    @objc private func didTapWatchlist() {
        delegate?.didSelectList(.watchlist)
    }

    @objc private func didTapFavorites() {
        delegate?.didSelectList(.favorites)
    }

    @objc private func didTapRated() {
        delegate?.didSelectList(.rated)
    }

    // MARK: - Helpers

    private func configureCards(_ movies: [ListsModels.MovieCardViewModel]) {
        cardsStack.arrangedSubviews.forEach {
            cardsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        guard !movies.isEmpty else {
            emptyStateLabel.text = emptyMessage(for: selectedList)
            cardsStack.addArrangedSubview(emptyStateLabel)
            return
        }

        movies.forEach { movie in
            let card = ListsMovieCardView()
            card.configure(viewModel: movie)
            card.delegate = self
            cardsStack.addArrangedSubview(card)
            card.heightAnchor.constraint(equalToConstant: 152).isActive = true
        }
    }

    private func setState(_ state: State) {
        let isLoading = state == .loading
        let isContent = state == .content
        let isError = state == .error

        scrollView.isHidden = !isContent
        errorStateView.isHidden = !isError
        authenticationPromptView.isHidden = true
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }

    private func updateTabs() {
        let buttons: [(UIButton, ListsModels.List)] = [
            (watchlistButton, .watchlist),
            (favoritesButton, .favorites),
            (ratedButton, .rated)
        ]
        buttons.forEach { button, list in
            let isSelected = list == selectedList
            button.setTitleColor(isSelected ? .textPrimary : .textSecondary, for: .normal)
            button.titleLabel?.font = .systemFont(
                ofSize: 16,
                weight: isSelected ? .semibold : .medium
            )
        }
    }

    private func makeTabButton(
        title: String,
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func emptyMessage(for list: ListsModels.List) -> String {
        switch list {
        case .watchlist:
            Strings.ListsScene.Empty.watchlist
        case .favorites:
            Strings.ListsScene.Empty.favorites
        case .rated:
            Strings.ListsScene.Empty.rated
        }
    }
}

// MARK: - ListsMovieCardViewDelegate

extension ListsView: ListsMovieCardViewDelegate {
    func didSelectMovie(id movieId: Int) {
        delegate?.didSelectMovie(id: movieId)
    }

    func didRequestRemoveMovie(id movieId: Int) {
        delegate?.didRequestRemoveMovie(id: movieId)
    }
}

// MARK: - ListsErrorStateViewDelegate

extension ListsView: ListsErrorStateViewDelegate {
    func didRequestRetry() {
        delegate?.didRequestRetry()
    }
}

extension ListsView: AuthenticationPromptViewDelegate {
    func didTapAuthenticationPrompt() {
        delegate?.didRequestAuthentication()
    }
}
