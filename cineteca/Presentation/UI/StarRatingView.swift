import UIKit
import Cartography

final class StarRatingView: UIView {

    // MARK: - UI Components

    private lazy var starsRow: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 2
        row.alignment = .center
        return row
    }()

    private var starImageViews: [UIImageView] = []

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        setupStarImageViews()
        setupSubviews()
        setupConstraints()
    }

    private func setupStarImageViews() {
        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        for _ in 0..<5 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.preferredSymbolConfiguration = config
            imageView.tintColor = .accentYellow
            starImageViews.append(imageView)
            starsRow.addArrangedSubview(imageView)
        }
    }

    private func setupSubviews() {
        addSubview(starsRow)
    }

    private func setupConstraints() {
        constrainStarsRow()
        constrainStarImageView()
    }

    private func constrainStarsRow() {
        constrain(starsRow, self) { row, superview in
            row.edges == superview.edges
        }
    }

    private func constrainStarImageView() {
        constrain(starImageViews[0]) { star in
            star.width == 12
            star.height == 12
        }
    }

    // MARK: - Configure

    func configure(rating: Double) {
        for index in 0..<5 {
            let starValue = Double(index) + 1
            let imageName: String
            if rating >= starValue {
                imageName = "star.fill"
            } else if rating >= starValue - 0.5 {
                imageName = "star.leadinghalf.filled"
            } else {
                imageName = "star"
            }
            starImageViews[index].image = UIImage(systemName: imageName)
        }
    }
}
