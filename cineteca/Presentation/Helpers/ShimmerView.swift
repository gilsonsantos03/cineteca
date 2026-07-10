import UIKit

final class ShimmerView: UIView {

    // MARK: - Properties

    private let cornerRadius: CGFloat
    private let gradientLayer = CAGradientLayer()
    private static let animationKey = "shimmer"

    // MARK: - Initialization

    init(cornerRadius: CGFloat = 4) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil, !isHidden {
            startShimmering()
        } else {
            stopShimmering()
        }
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .cardBackground
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        setupGradient()
    }

    private func setupGradient() {
        let baseColor = UIColor.cardBackground.cgColor
        let highlightColor = UIColor.white.withAlphaComponent(0.08).cgColor
        gradientLayer.colors = [baseColor, highlightColor, baseColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        layer.addSublayer(gradientLayer)
    }

    // MARK: - Public API

    func startShimmering() {
        guard gradientLayer.animation(forKey: Self.animationKey) == nil else { return }
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: Self.animationKey)
    }

    func stopShimmering() {
        gradientLayer.removeAnimation(forKey: Self.animationKey)
    }
}
