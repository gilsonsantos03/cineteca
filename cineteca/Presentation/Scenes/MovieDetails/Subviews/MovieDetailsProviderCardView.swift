import UIKit
import Cartography

final class MovieDetailsProviderCardView: UIView {

    // MARK: - UI Components

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .textPrimary
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [logoImageView, nameLabel])
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .center
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
        backgroundColor = .cardBackground
        layer.cornerRadius = 10
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(contentStack)
    }

    private func setupConstraints() {
        constrainSelf()
        constrainContentStack()
        constrainLogoImageView()
    }

    private func constrainSelf() {
        constrain(self) { view in
            view.width == 68
            view.height == 70
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, self) { stack, container in
            stack.top == container.top + 8
            stack.bottom == container.bottom - 8
            stack.left == container.left + 8
            stack.right == container.right - 8
        }
    }

    private func constrainLogoImageView() {
        constrain(logoImageView) { imageView in
            imageView.width == 32
            imageView.height == 32
        }
    }

    // MARK: - Configure

    func configure(viewModel: MovieDetailsModels.WatchProviderViewModel) {
        nameLabel.text = viewModel.name
        logoImageView.loadImage(from: viewModel.logoURL)
    }
}
