import UIKit
import Cartography

protocol ProfileFavoriteFilmViewDelegate: AnyObject {
    func didTapFavoriteFilm(movieId: Int)
}

final class ProfileFavoriteFilmView: UIView {

    weak var delegate: ProfileFavoriteFilmViewDelegate?
    private var movieId: Int?

    // MARK: - UI Components

    private lazy var backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .cardBackground
        imageView.layer.cornerRadius = 16
        return imageView
    }()

    private let gradientLayer = CAGradientLayer()

    private lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.ProfileScene.FavoriteFilm.badge
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .black
        return label
    }()

    private lazy var badgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .accentYellow
        view.layer.cornerRadius = 6
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = backdropImageView.bounds
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapFavoriteFilm)))
        setupGradient()
        setupSubviews()
        setupConstraints()
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.75).cgColor
        ]
        gradientLayer.locations = [0.4, 1.0]
        backdropImageView.layer.addSublayer(gradientLayer)
    }

    private func setupSubviews() {
        addSubview(backdropImageView)
        backdropImageView.addSubview(badgeView)
        badgeView.addSubview(badgeLabel)
        backdropImageView.addSubview(titleLabel)
    }

    private func setupConstraints() {
        constrainBackdropImageView()
        constrainBadgeView()
        constrainBadgeLabel()
        constrainTitleLabel()
    }

    private func constrainBackdropImageView() {
        constrain(backdropImageView, self) { image, superview in
            image.top == superview.top
            image.leading == superview.leading + 20
            image.trailing == superview.trailing - 20
            image.height == 160
            image.bottom == superview.bottom
        }
    }

    private func constrainBadgeView() {
        constrain(badgeView, backdropImageView) { badge, image in
            badge.top == image.top + 12
            badge.leading == image.leading + 12
        }
    }

    private func constrainBadgeLabel() {
        constrain(badgeLabel, badgeView) { label, badge in
            label.top == badge.top + 4
            label.bottom == badge.bottom - 4
            label.leading == badge.leading + 8
            label.trailing == badge.trailing - 8
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, backdropImageView) { label, image in
            label.leading == image.leading + 16
            label.trailing == image.trailing - 16
            label.bottom == image.bottom - 16
        }
    }

    // MARK: - Configure

    func configure(viewModel: ProfileModels.FavoriteFilmViewModel) {
        movieId = viewModel.movieId
        titleLabel.text = viewModel.title.isEmpty
            ? Strings.ProfileScene.FavoriteFilm.empty
            : viewModel.title
        titleLabel.textColor = viewModel.movieId == nil ? .textSecondary : .textPrimary
        isUserInteractionEnabled = viewModel.movieId != nil
        backdropImageView.loadImage(from: viewModel.backdropURL)
    }

    @objc private func didTapFavoriteFilm() {
        guard let movieId else { return }
        delegate?.didTapFavoriteFilm(movieId: movieId)
    }
}
