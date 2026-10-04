import UIKit
import Cartography

final class StatCardsView: UIView {

    struct ViewModel {
        let filmsCount: String
        let hoursWatched: String
        let reviewsCount: String
    }

    // MARK: - UI Components

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()

    private lazy var filmsCard = StatCardView()
    private lazy var hoursCard = StatCardView()
    private lazy var reviewsCard = StatCardView()

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
        addSubview(stackView)
        stackView.addArrangedSubview(filmsCard)
        stackView.addArrangedSubview(hoursCard)
        stackView.addArrangedSubview(reviewsCard)
    }

    private func setupConstraints() {
        constrainStackView()
    }

    private func constrainStackView() {
        constrain(stackView, self) { stack, superview in
            stack.top == superview.top
            stack.left == superview.left + 20
            stack.right == superview.right - 20
            stack.bottom == superview.bottom
            stack.height == 72
        }
    }

    // MARK: - Configure

    func configure(viewModel: ViewModel) {
        filmsCard.configure(value: viewModel.filmsCount, label: Strings.UI.StatCards.films)
        hoursCard.configure(value: viewModel.hoursWatched, label: Strings.UI.StatCards.hours)
        reviewsCard.configure(value: viewModel.reviewsCount, label: Strings.UI.StatCards.reviews)
    }
}

private final class StatCardView: UIView {

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .textSecondary
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .cardBackground
        layer.cornerRadius = 12
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    private func setupSubviews() {
        addSubview(valueLabel)
        addSubview(titleLabel)
    }

    private func setupConstraints() {
        constrainValueLabel()
        constrainTitleLabel()
    }

    private func constrainValueLabel() {
        constrain(valueLabel, self) { label, superview in
            label.centerX == superview.centerX
            label.centerY == superview.centerY - 8
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, valueLabel, self) { title, value, superview in
            title.top == value.bottom + 4
            title.centerX == superview.centerX
        }
    }

    func configure(value: String, label: String) {
        valueLabel.text = value
        titleLabel.text = label
    }
}
