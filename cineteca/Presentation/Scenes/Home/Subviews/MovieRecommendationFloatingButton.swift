import UIKit

protocol MovieRecommendationFloatingButtonDelegate: AnyObject {
    func didTapMovieRecommendation()
}

final class MovieRecommendationFloatingButton: UIButton {
    weak var actionDelegate: MovieRecommendationFloatingButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let cornerRadius = bounds.height / 2
        layer.cornerRadius = cornerRadius
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }

    private func setup() {
        var configuration = UIButton.Configuration.filled()
        configuration.title = Strings.MovieRecommendationScene.homeButton
        configuration.image = UIImage(systemName: "sparkles")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 8
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 18,
            bottom: 12,
            trailing: 18
        )
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = .accentYellow
        configuration.baseForegroundColor = .black
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var transformedAttributes = attributes
            let baseFont = UIFont.systemFont(ofSize: 15, weight: .bold)
            transformedAttributes.font = UIFontMetrics(
                forTextStyle: .subheadline
            ).scaledFont(for: baseFont)
            return transformedAttributes
        }
        self.configuration = configuration

        accessibilityIdentifier = "home.movieRecommendationButton"
        accessibilityTraits = .button
        titleLabel?.adjustsFontForContentSizeCategory = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    @objc private func didTap() {
        actionDelegate?.didTapMovieRecommendation()
    }
}
