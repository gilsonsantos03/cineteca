import UIKit
import Cartography

protocol MovieReviewRatingScaleViewDelegate: AnyObject {
    func didSelectRating(_ rating: Double)
}

// MARK: - Movie Review Rating Scale

final class MovieReviewRatingScaleView: UIView {
    // MARK: Properties

    weak var delegate: MovieReviewRatingScaleViewDelegate?

    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        for rating in 0...10 {
            let button = UIButton(type: .system)
            button.tag = rating
            button.setTitle(String(rating), for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            button.disableHighlighting()
            button.addTarget(self, action: #selector(didTapRating(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
        return stack
    }()

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        addSubview(stack)
        setupConstraints()
    }

    private func setupConstraints() {
        constrain(stack, self) { stack, superview in
            stack.edges == superview.edges
        }
    }

    // MARK: Configuration

    func configure(selectedRating: Double?) {
        for view in stack.arrangedSubviews {
            guard let button = view as? UIButton else { continue }
            let isSelected = selectedRating.map {
                abs($0 - Double(button.tag)) < 0.001
            } ?? false
            button.setTitleColor(isSelected ? .accentYellow : .textSecondary, for: .normal)
            button.titleLabel?.font = .systemFont(
                ofSize: 12,
                weight: isSelected ? .bold : .medium
            )
        }
    }

    // MARK: Actions

    @objc private func didTapRating(_ sender: UIButton) {
        delegate?.didSelectRating(Double(sender.tag))
    }
}

private extension UIButton {
    func disableHighlighting() {
        adjustsImageWhenHighlighted = false
        showsTouchWhenHighlighted = false
    }
}
