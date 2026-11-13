import UIKit
import Cartography

protocol EmptyMovieSelectionCardViewDelegate: AnyObject {
    func didTapSelectMovie(at index: Int)
}

final class EmptyMovieSelectionCardView: UIView {
    weak var delegate: EmptyMovieSelectionCardViewDelegate?
    private var index = 0

    private lazy var plusImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "plus"))
        view.tintColor = .textSecondary
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieRecommendationScene.selectMovie
        label.textColor = .textSecondary
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        backgroundColor = .cardBackground
        layer.cornerRadius = 20
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectMovieTapped)))
        addSubview(plusImageView)
        addSubview(titleLabel)
        setupConstraints()
    }

    private func setupConstraints() {
        constrainPlusImageView()
        constrainTitleLabel()
    }

    private func constrainPlusImageView() {
        constrain(plusImageView, self) { imageView, container in
            imageView.centerX == container.centerX
            imageView.centerY == container.centerY - 20
            container.height == 300
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, plusImageView, self) { title, imageView, container in
            title.top == imageView.bottom + 12
            title.leading == container.leading + 8
            title.trailing == container.trailing - 8
        }
    }

    func configure(index: Int) {
        self.index = index
    }

    @objc private func selectMovieTapped() {
        delegate?.didTapSelectMovie(at: index)
    }
}
