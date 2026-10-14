import UIKit
import Cartography

protocol EditProfileFavoriteFilmViewDelegate: AnyObject {
    func didTapChangeFavoriteFilm()
}

final class EditProfileFavoriteFilmView: UIView {

    // MARK: - Properties

    weak var delegate: EditProfileFavoriteFilmViewDelegate?

    // MARK: - UI Components

    private lazy var backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .cardBackground
        imageView.layer.cornerRadius = 16
        return imageView
    }()

    private let gradientLayer = CAGradientLayer()

    private lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.EditProfileScene.FavoriteFilm.badge
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
        label.numberOfLines = 2
        return label
    }()

    private lazy var changeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.EditProfileScene.FavoriteFilm.change, for: .normal)
        button.setTitleColor(.accentYellow, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(didTapChange), for: .touchUpInside)
        return button
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
        backdropImageView.addSubview(changeButton)
    }

    private func setupConstraints() {
        constrainBackdropImageView()
        constrainBadgeView()
        constrainBadgeLabel()
        constrainTitleLabel()
        constrainChangeButton()
    }

    private func constrainBackdropImageView() {
        constrain(backdropImageView, self) { image, superview in
            image.edges == superview.edges
            image.height == 160
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
        constrain(titleLabel, backdropImageView, changeButton) { title, image, change in
            title.left == image.left + 16
            title.bottom == image.bottom - 16
            title.right <= change.left - 12
        }
    }

    private func constrainChangeButton() {
        constrain(changeButton, backdropImageView) { change, image in
            change.right == image.right - 16
            change.centerY == image.bottom - 28
        }
    }

    // MARK: - Configure

    func configure(viewModel: EditProfileModels.FavoriteFilmViewModel?) {
        titleLabel.text = viewModel?.title ?? Strings.EditProfileScene.FavoriteFilm.empty
        backdropImageView.image = nil
        if let backdropURL = viewModel?.backdropURL {
            backdropImageView.loadImage(from: backdropURL)
        }
    }

    // MARK: - Actions

    @objc private func didTapChange() {
        delegate?.didTapChangeFavoriteFilm()
    }
}
