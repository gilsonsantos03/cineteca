import UIKit
import Cartography

final class ProfileContentView: UIView {

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .appBackground
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    private lazy var headerView = ProfileHeaderView()
    private lazy var favoriteFilmView = ProfileFavoriteFilmView()
    private lazy var statsView = ProfileStatsView()
    private lazy var recentReviewsView = ProfileRecentReviewsView()
    private lazy var settingsView = ProfileSettingsView()

    private lazy var signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.ProfileScene.signOut, for: .normal)
        button.setTitleColor(UIColor(red: 0.95, green: 0.28, blue: 0.28, alpha: 1), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.isUserInteractionEnabled = false
        return button
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
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(favoriteFilmView)
        contentStack.addArrangedSubview(statsView)
        contentStack.addArrangedSubview(recentReviewsView)
        contentStack.addArrangedSubview(settingsView)
        contentStack.addArrangedSubview(signOutButton)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
    }

    private func setupConstraints() {
        constrainScrollView()
        constrainContentStack()
        constrainSignOutButton()
    }

    private func constrainScrollView() {
        constrain(scrollView, self) { scroll, superview in
            scroll.edges == superview.edges
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView) { stack, scroll in
            stack.top == scroll.top + 16
            stack.left == scroll.left
            stack.right == scroll.right
            stack.bottom == scroll.bottom
            stack.width == scroll.width
        }
    }

    private func constrainSignOutButton() {
        constrain(signOutButton) { button in
            button.height == 44
        }
    }

    // MARK: - Configure

    func configure(content: ProfileModels.FetchProfile.ViewModel.Content) {
        headerView.configure(viewModel: content.header)
        favoriteFilmView.configure(viewModel: content.favoriteFilm)
        statsView.configure(viewModel: content.stats)
        recentReviewsView.configure(viewModel: content.recentReviews)
        settingsView.configure(viewModel: content.settings)
    }

    // MARK: - Helpers

    private func makeSpacer(height: CGFloat) -> UIView {
        let view = UIView()
        constrain(view) { spacer in
            spacer.height == height
        }
        return view
    }
}
