import UIKit
import Cartography

protocol HomeContentViewDelegate: AnyObject {
    func homeContentViewDidRequestRefresh(_ view: HomeContentView)
    func homeContentView(_ view: HomeContentView, didSelectGenreAt index: Int)
}

final class HomeContentView: UIView {

    // MARK: - Properties

    weak var delegate: HomeContentViewDelegate?

    // MARK: - UI Components

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .textSecondary
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return refreshControl
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .appBackground
        scrollView.refreshControl = refreshControl
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private lazy var featuredView = FeaturedView()
    private lazy var genreFilterView = GenreFilterView()
    private lazy var nowPlayingSectionView = MovieSectionView(title: Strings.HomeScene.Section.nowPlaying)
    private lazy var trendingSectionView = MovieSectionView(title: Strings.HomeScene.Section.trending)
    private lazy var topRatedSectionView = MovieSectionView(title: Strings.HomeScene.Section.topRated)
    private lazy var weeklyDigestView = WeeklyDigestView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .appBackground
        genreFilterView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(featuredView)
        contentStack.addArrangedSubview(genreFilterView)
        contentStack.addArrangedSubview(nowPlayingSectionView)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
        contentStack.addArrangedSubview(trendingSectionView)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
        contentStack.addArrangedSubview(topRatedSectionView)
        contentStack.addArrangedSubview(makeSpacer(height: 24))
        contentStack.addArrangedSubview(weeklyDigestView)
        contentStack.addArrangedSubview(makeSpacer(height: 32))
    }

    private func setupConstraints() {
        constrainScrollView()
        constrainContentStack()
    }

    private func constrainScrollView() {
        constrain(scrollView, self) { scrollView, superview in
            scrollView.edges == superview.edges
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView) { stack, scrollView in
            stack.top == scrollView.top
            stack.left == scrollView.left
            stack.right == scrollView.right
            stack.bottom == scrollView.bottom
            stack.width == scrollView.width
        }
    }

    // MARK: - Configure

    func configure(viewModel: HomeModels.FetchContent.ViewModel) {
        featuredView.configure(viewModel: viewModel.featured)
        genreFilterView.configure(viewModel: viewModel.genreFilter)
        nowPlayingSectionView.configure(movies: viewModel.nowPlaying)
        trendingSectionView.configure(movies: viewModel.trending)
        topRatedSectionView.configure(movies: viewModel.topRated)
    }

    func endRefreshing() {
        refreshControl.endRefreshing()
    }

    // MARK: - Actions

    @objc private func didPullToRefresh() {
        delegate?.homeContentViewDidRequestRefresh(self)
    }

    // MARK: - Helpers

    private func makeSpacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        constrain(spacer) { $0.height == height }
        return spacer
    }
}

// MARK: - GenreFilterViewDelegate

extension HomeContentView: GenreFilterViewDelegate {
    func genreFilterView(_ view: GenreFilterView, didSelectGenreAt index: Int) {
        delegate?.homeContentView(self, didSelectGenreAt: index)
    }
}
