import UIKit
import Cartography

protocol MovieDetailsActionsViewDelegate: AnyObject {
    func movieDetailsActionsView(_ view: MovieDetailsActionsView, didTapRate button: UIButton)
    func movieDetailsActionsView(_ view: MovieDetailsActionsView, didTapFavorite button: UIButton)
    func movieDetailsActionsView(_ view: MovieDetailsActionsView, didTapWatchlist button: UIButton)
}

final class MovieDetailsActionsView: UIStackView {

    // MARK: - Properties

    weak var delegate: MovieDetailsActionsViewDelegate?

    private enum ActionKind: String {
        case rate
        case favorite
        case watchlist

        var title: String {
            switch self {
            case .rate:
                Strings.MovieDetailsScene.Action.rate
            case .favorite:
                Strings.MovieDetailsScene.Action.favorite
            case .watchlist:
                Strings.MovieDetailsScene.Action.watchlist
            }
        }

        var symbol: String {
            switch self {
            case .rate:
                "star"
            case .favorite:
                "heart"
            case .watchlist:
                "plus"
            }
        }

        var selectedSymbol: String {
            switch self {
            case .rate:
                "star.fill"
            case .favorite:
                "heart.fill"
            case .watchlist:
                "checkmark"
            }
        }

        var iconColor: UIColor {
            switch self {
            case .rate:
                .accentYellow
            case .favorite:
                .systemRed
            case .watchlist:
                .white
            }
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        axis = .horizontal
        spacing = 12
        distribution = .fillEqually

        addArrangedSubview(makeButton(kind: .rate, selector: #selector(didTapRate)))
        addArrangedSubview(makeButton(kind: .favorite, selector: #selector(didTapFavorite)))
        addArrangedSubview(makeButton(kind: .watchlist, selector: #selector(didTapWatchlist)))

        constrain(self) { view in
            view.height == 76
        }
    }

    // MARK: - Actions

    @objc private func didTapRate(_ sender: UIButton) {
        toggle(sender, kind: .rate)
        delegate?.movieDetailsActionsView(self, didTapRate: sender)
    }

    @objc private func didTapFavorite(_ sender: UIButton) {
        toggle(sender, kind: .favorite)
        delegate?.movieDetailsActionsView(self, didTapFavorite: sender)
    }

    @objc private func didTapWatchlist(_ sender: UIButton) {
        toggle(sender, kind: .watchlist)
        delegate?.movieDetailsActionsView(self, didTapWatchlist: sender)
    }

    // MARK: - Helpers

    private func makeButton(kind: ActionKind, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = kind.rawValue
        button.addTarget(self, action: selector, for: .touchUpInside)
        applyStyle(to: button, kind: kind, isSelected: false)
        return button
    }

    private func applyStyle(to button: UIButton, kind: ActionKind, isSelected: Bool) {
        let symbol = isSelected ? kind.selectedSymbol : kind.symbol
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        let icon = UIImage(systemName: symbol, withConfiguration: symbolConfiguration)?
            .withTintColor(kind.iconColor, renderingMode: .alwaysOriginal)

        var configuration = UIButton.Configuration.plain()
        configuration.image = icon
        configuration.title = kind.title
        configuration.imagePlacement = .top
        configuration.imagePadding = 6
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .cardBackground
        configuration.background.cornerRadius = 12
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = .systemFont(ofSize: 12, weight: .medium)
            attributes.foregroundColor = .white
            return attributes
        }
        button.configuration = configuration
    }

    private func toggle(_ button: UIButton, kind: ActionKind) {
        button.isSelected.toggle()
        applyStyle(to: button, kind: kind, isSelected: button.isSelected)
    }
}
