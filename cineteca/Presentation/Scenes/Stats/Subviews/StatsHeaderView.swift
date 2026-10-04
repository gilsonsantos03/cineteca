import UIKit
import Cartography

final class StatsHeaderView: UIView {

    // MARK: - UI Components

    private lazy var yearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .accentYellow
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .textPrimary
        label.numberOfLines = 0
        return label
    }()

    private lazy var filmImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "film"))
        imageView.tintColor = .accentYellow
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleRow: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, filmImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [yearLabel, titleRow])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
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
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(contentStack)
    }

    private func setupConstraints() {
        constrainContentStack()
        constrainFilmImageView()
    }

    private func constrainContentStack() {
        constrain(contentStack, self) { stack, superview in
            stack.top == superview.top
            stack.left == superview.left + 20
            stack.right == superview.right - 20
            stack.bottom == superview.bottom
        }
    }

    private func constrainFilmImageView() {
        constrain(filmImageView) { imageView in
            imageView.width == 26
            imageView.height == 26
        }
    }

    // MARK: - Configure

    func configure(viewModel: StatsModels.HeaderViewModel) {
        yearLabel.text = viewModel.yearText
        titleLabel.text = viewModel.title
    }
}
