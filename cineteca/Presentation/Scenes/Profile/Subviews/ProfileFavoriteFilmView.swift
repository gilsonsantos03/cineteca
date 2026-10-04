import UIKit
import Cartography

final class ProfileFavoriteFilmView: UIView {

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
        isUserInteractionEnabled = false
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
            image.left == superview.left + 20
            image.right == superview.right - 20
            image.height == 160
            image.bottom == superview.bottom
        }
    }

    private func constrainBadgeView() {
        constrain(badgeView, backdropImageView) { badge, image in
            badge.top == image.top + 12
            badge.left == image.left + 12
        }
    }

    private func constrainBadgeLabel() {
        constrain(badgeLabel, badgeView) { label, badge in
            label.top == badge.top + 4
            label.bottom == badge.bottom - 4
            label.left == badge.left + 8
            label.right == badge.right - 8
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, backdropImageView) { label, image in
            label.left == image.left + 16
            label.right == image.right - 16
            label.bottom == image.bottom - 16
        }
    }

    // MARK: - Configure

    func configure(viewModel: ProfileModels.FavoriteFilmViewModel) {
        titleLabel.text = viewModel.title
        backdropImageView.loadImage(from: viewModel.backdropURL)
    }
}
