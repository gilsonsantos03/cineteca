import UIKit

// MARK: - Movie Review Rating Circle

final class MovieReviewRatingCircleView: UIView {
    // MARK: Properties

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let ratingLabel = UILabel()
    private let scaleLabel = UILabel()

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Setup

    private func setup() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.cardBackground.cgColor
        trackLayer.lineWidth = 5
        layer.addSublayer(trackLayer)

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.accentYellow.cgColor
        progressLayer.lineWidth = 5
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)

        ratingLabel.font = .systemFont(ofSize: 42, weight: .bold)
        ratingLabel.textColor = .textPrimary
        ratingLabel.textAlignment = .center
        addSubview(ratingLabel)

        scaleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        scaleLabel.textColor = .textSecondary
        scaleLabel.textAlignment = .center
        addSubview(scaleLabel)
    }

    // MARK: Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset = trackLayer.lineWidth / 2
        let circleRect = bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: min(circleRect.width, circleRect.height) / 2,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath

        ratingLabel.frame = CGRect(
            x: 12,
            y: bounds.midY - 28,
            width: bounds.width - 24,
            height: 48
        )
        scaleLabel.frame = CGRect(
            x: 12,
            y: bounds.midY + 20,
            width: bounds.width - 24,
            height: 16
        )
    }

    // MARK: Configuration

    func configure(rating: Double?) {
        if let rating {
            ratingLabel.text = rating == rating.rounded()
                ? String(format: "%.0f", rating)
                : String(format: "%.1f", rating)
            progressLayer.strokeEnd = CGFloat(rating / 10)
        } else {
            ratingLabel.text = "—"
            progressLayer.strokeEnd = 0
        }
        scaleLabel.text = Strings.MovieDetailsScene.Review.outOfTen
    }
}
