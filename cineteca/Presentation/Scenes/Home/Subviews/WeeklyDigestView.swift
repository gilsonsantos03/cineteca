import UIKit
import Cartography

final class WeeklyDigestView: UIView {

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your weekly digest"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "4 new films match your taste"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var digestTextStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private lazy var starImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = .accentYellow
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        layer.cornerRadius = 14
        layer.masksToBounds = true
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(digestTextStack)
        addSubview(starImageView)
    }

    private func setupConstraints() {
        constrainDigestTextStack()
        constrainStarImageView()
        constrainSelf()
    }

    private func constrainDigestTextStack() {
        constrain(digestTextStack, self) { stack, superview in
            stack.top == superview.top + 16
            stack.bottom == superview.bottom - 16
            stack.left == superview.left + 16
        }
    }

    private func constrainStarImageView() {
        constrain(starImageView, self, digestTextStack) { imageView, superview, stack in
            imageView.centerY == stack.centerY
            imageView.right == superview.right - 16
            imageView.left >= stack.right + 8
            imageView.width == 28
            imageView.height == 28
        }
    }

    private func constrainSelf() {
        constrain(self) { superview in
            superview.height == 72
        }
    }
}
