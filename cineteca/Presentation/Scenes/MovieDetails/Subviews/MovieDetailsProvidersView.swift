import UIKit
import Cartography

protocol MovieDetailsProvidersViewDelegate: AnyObject {
    func didRequestWatchOptions(url: URL)
}

final class MovieDetailsProvidersView: UIStackView {

    // MARK: - Properties

    weak var delegate: MovieDetailsProvidersViewDelegate?
    private var watchOptionsURL: URL?
    private var providerGroups: [MovieDetailsModels.WatchProviderGroupViewModel] = []
    private var selectedCategoryIndex = 0
    private var categoryButtons: [UIButton] = []

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieDetailsScene.Section.whereToWatch
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var categoryScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var categoryStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()

    private lazy var providersScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var providersStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        return stack
    }()

    private lazy var attributionButton: UIButton = {
        let button = UIButton(type: .system)
        let title = Strings.MovieDetailsScene.ProviderCategory.poweredByJustWatch
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]
        )
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setTitleColor(.textSecondary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(didTapAttribution), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        axis = .vertical
        spacing = 10
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        categoryScrollView.addSubview(categoryStack)
        providersScrollView.addSubview(providersStack)
        addArrangedSubview(titleLabel)
        addArrangedSubview(categoryScrollView)
        addArrangedSubview(providersScrollView)
        addArrangedSubview(attributionButton)
    }

    private func setupConstraints() {
        constrainCategoryStack()
        constrainCategoryScrollView()
        constrainProvidersStack()
        constrainProvidersScrollView()
    }

    private func constrainCategoryStack() {
        constrain(categoryStack, categoryScrollView.contentLayoutGuide, categoryScrollView.frameLayoutGuide) { stack, content, frame in
            stack.top == content.top
            stack.bottom == content.bottom
            stack.left == content.left
            stack.right == content.right
            stack.height == frame.height
        }
    }

    private func constrainCategoryScrollView() {
        constrain(categoryScrollView) { scrollView in
            scrollView.height == 32
        }
    }

    private func constrainProvidersStack() {
        constrain(providersStack, providersScrollView.contentLayoutGuide, providersScrollView.frameLayoutGuide) { stack, content, frame in
            stack.top == content.top
            stack.bottom == content.bottom
            stack.left == content.left
            stack.right == content.right
            stack.height == frame.height
        }
    }

    private func constrainProvidersScrollView() {
        constrain(providersScrollView) { scrollView in
            scrollView.height == 82
        }
    }

    // MARK: - Configure

    func configure(
        groups: [MovieDetailsModels.WatchProviderGroupViewModel],
        watchOptionsURL: URL?
    ) {
        self.providerGroups = groups
        self.watchOptionsURL = watchOptionsURL
        selectedCategoryIndex = 0
        categoryButtons.removeAll()
        removeArrangedSubviews(from: categoryStack)
        removeArrangedSubviews(from: providersStack)

        groups.enumerated().forEach { index, group in
            let button = makeCategoryButton(title: group.title, index: index)
            categoryButtons.append(button)
            categoryStack.addArrangedSubview(button)
        }

        updateProviders()
        attributionButton.isEnabled = watchOptionsURL != nil
        isHidden = groups.isEmpty
    }

    private func makeCategoryButton(title: String, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = .systemFont(ofSize: 12, weight: .medium)
            return attributes
        }
        button.configuration = configuration
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1
        button.tag = index
        button.accessibilityLabel = title
        button.configurationUpdateHandler = { button in
            guard var configuration = button.configuration else { return }
            configuration.baseForegroundColor = button.isSelected ? .black : .textPrimary
            configuration.background.backgroundColor = button.isSelected ? .accentYellow : .cardBackground
            button.configuration = configuration
            button.layer.borderColor = button.isSelected
                ? UIColor.accentYellow.cgColor
                : UIColor.borderSubtle.resolvedColor(with: button.traitCollection).cgColor
            button.accessibilityTraits = button.isSelected ? [.button, .selected] : .button
        }
        button.addTarget(self, action: #selector(didSelectCategory(_:)), for: .touchUpInside)
        button.isSelected = index == selectedCategoryIndex
        button.setNeedsUpdateConfiguration()
        return button
    }

    private func updateProviders() {
        removeArrangedSubviews(from: providersStack)
        guard providerGroups.indices.contains(selectedCategoryIndex) else { return }

        providerGroups[selectedCategoryIndex].providers.forEach { provider in
            let cardView = MovieDetailsProviderCardView()
            cardView.configure(viewModel: provider)
            providersStack.addArrangedSubview(cardView)
        }
    }

    private func removeArrangedSubviews(from stack: UIStackView) {
        stack.arrangedSubviews.forEach { arrangedSubview in
            stack.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
    }

    // MARK: - Actions

    @objc private func didSelectCategory(_ sender: UIButton) {
        guard providerGroups.indices.contains(sender.tag), sender.tag != selectedCategoryIndex else { return }
        selectedCategoryIndex = sender.tag
        categoryButtons.forEach { button in
            button.isSelected = button.tag == selectedCategoryIndex
            button.setNeedsUpdateConfiguration()
        }
        updateProviders()
    }

    @objc private func didTapAttribution() {
        guard let watchOptionsURL else { return }
        delegate?.didRequestWatchOptions(url: watchOptionsURL)
    }
}
