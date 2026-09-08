import UIKit
import Cartography

final class MovieDetailsRatingView: UIView {

    // MARK: - UI Components

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .textSecondary
        return label
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
        layer.cornerRadius = MovieDetailsCardMetrics.cornerRadius
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(valueLabel)
        addSubview(captionLabel)
    }

    private func setupConstraints() {
        constrainSelf()
        constrainValueLabel()
        constrainCaptionLabel()
    }

    private func constrainSelf() {
        constrain(self) { view in
            view.height == MovieDetailsCardMetrics.height
        }
    }

    private func constrainValueLabel() {
        constrain(valueLabel, self) { label, superview in
            label.top == superview.top + 12
            label.centerX == superview.centerX
        }
    }

    private func constrainCaptionLabel() {
        constrain(captionLabel, valueLabel, self) { caption, value, superview in
            caption.top == value.bottom + 3
            caption.centerX == superview.centerX
            caption.bottom == superview.bottom - 12
        }
    }

    // MARK: - Configure

    func configure(rating: String) {
        valueLabel.text = "★ \(rating)"
        captionLabel.text = Strings.MovieDetailsScene.Rating.tmdb
    }
}
