import UIKit
import Cartography

protocol WatchTrailerButtonDelegate: AnyObject {
    func didTap()
}

final class WatchTrailerButton: UIButton {

    enum Style {
        case featured
        case detailsCard
    }

    // MARK: - Properties

    weak var delegate: WatchTrailerButtonDelegate?
    private let style: Style

    // MARK: - Initialization

    init(style: Style = .featured) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let icon = UIImage(systemName: "play.fill", withConfiguration: symbolConfiguration)

        var configuration = UIButton.Configuration.plain()
        configuration.image = icon
        configuration.title = Strings.UI.watchTrailer
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.baseForegroundColor = .black
        configuration.background.backgroundColor = .accentYellow
        configuration.background.cornerRadius = style == .detailsCard ? MovieDetailsCardMetrics.cornerRadius : 22
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = .systemFont(ofSize: 16, weight: .semibold)
            return attributes
        }
        self.configuration = configuration
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
        constrainSelf()
    }

    private func constrainSelf() {
        let height = style == .detailsCard ? MovieDetailsCardMetrics.height : 44
        constrain(self) { button in
            button.height == height
        }
    }

    // MARK: - Actions

    @objc private func didTap() {
        delegate?.didTap()
    }
}
