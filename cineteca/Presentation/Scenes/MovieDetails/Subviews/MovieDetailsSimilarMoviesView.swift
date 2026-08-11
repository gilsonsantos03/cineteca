import UIKit
import Cartography

protocol MovieDetailsSimilarMoviesViewDelegate: AnyObject {
    func movieDetailsSimilarMoviesView(_ view: MovieDetailsSimilarMoviesView, didSelectMovie movieId: Int)
}

final class MovieDetailsSimilarMoviesView: UIStackView {

    // MARK: - Properties

    weak var delegate: MovieDetailsSimilarMoviesViewDelegate?

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieDetailsScene.Section.similar
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        axis = .vertical
        spacing = 10
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        scrollView.addSubview(contentStack)
        addArrangedSubview(titleLabel)
        addArrangedSubview(scrollView)
    }

    private func setupConstraints() {
        constrainContentStack()
        constrainScrollView()
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView.contentLayoutGuide, scrollView.frameLayoutGuide) { stack, content, frame in
            stack.top == content.top
            stack.bottom == content.bottom
            stack.left == content.left
            stack.right == content.right
            stack.height == frame.height
        }
    }

    private func constrainScrollView() {
        constrain(scrollView) { scrollView in
            scrollView.height == 185
        }
    }

    // MARK: - Configure

    func configure(_ movies: [MovieDetailsModels.SimilarMovieViewModel]) {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        movies.forEach { movie in
            let cardView = MovieDetailsSimilarMovieCardView()
            cardView.delegate = self
            cardView.configure(viewModel: movie)
            contentStack.addArrangedSubview(cardView)
        }
        isHidden = movies.isEmpty
    }
}

// MARK: - MovieDetailsSimilarMovieCardViewDelegate

extension MovieDetailsSimilarMoviesView: MovieDetailsSimilarMovieCardViewDelegate {
    func similarMovieCardView(_ view: MovieDetailsSimilarMovieCardView, didSelectMovie movieId: Int) {
        delegate?.movieDetailsSimilarMoviesView(self, didSelectMovie: movieId)
    }
}
