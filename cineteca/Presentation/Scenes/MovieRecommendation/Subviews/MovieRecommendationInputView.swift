import UIKit
import Cartography

protocol MovieRecommendationInputViewDelegate: AnyObject {
    func didRequestRecommendation(mode: MovieRecommendationMode)
    func didRequestMovieSelection(at index: Int)
    func didRemoveMovie(at index: Int)
}

final class MovieRecommendationInputView: UIView {

    // MARK: - Properties

    weak var delegate: MovieRecommendationInputViewDelegate?

    private var selectedMovies: [MovieRecommendationModels.SelectedMovieViewModel] = []
    private var selectedModeIndex = 0

    // MARK: - UI Components

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()

    private lazy var introLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieRecommendationScene.subtitle
        label.textColor = .textSecondary
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 0
        return label
    }()

    private lazy var momentModeButton = makeModeButton(
        title: Strings.MovieRecommendationScene.momentMode,
        imageName: "sparkles",
        tag: 0
    )

    private lazy var blendModeButton = makeModeButton(
        title: Strings.MovieRecommendationScene.blendMode,
        imageName: "shuffle",
        tag: 1
    )

    private lazy var modeTabsView = UIView()

    private lazy var modeTabsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [momentModeButton, blendModeButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var modeIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .accentYellow
        return view
    }()

    private lazy var promptTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .cardBackground
        textView.textColor = .textPrimary
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.layer.cornerRadius = 14
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.accessibilityLabel = Strings.MovieRecommendationScene.promptPlaceholder
        return textView
    }()

    private lazy var promptPlaceholder: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieRecommendationScene.promptPlaceholder
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .textSecondary
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        return label
    }()

    private lazy var promptContainer: UIView = {
        let container = UIView()
        container.addSubview(promptTextView)
        container.addSubview(promptPlaceholder)
        return container
    }()

    private lazy var movieSelectionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 12
        return stack
    }()

    private lazy var generateButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = Strings.MovieRecommendationScene.recommendButton
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 20,
            bottom: 12,
            trailing: 20
        )
        configuration.baseBackgroundColor = .accentYellow
        configuration.baseForegroundColor = .black

        let button = UIButton(configuration: configuration)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "movieRecommendation.generateButton"
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        setupSubviews()
        setupConstraints()
        updateInputMode()
        renderSelectedMovies()
    }

    private func setupSubviews() {
        addSubview(contentStack)
        modeTabsView.addSubview(modeTabsStack)
        modeTabsView.addSubview(modeIndicator)
        contentStack.addArrangedSubview(introLabel)
        contentStack.addArrangedSubview(modeTabsView)
        contentStack.addArrangedSubview(promptContainer)
        contentStack.addArrangedSubview(movieSelectionStack)
        contentStack.addArrangedSubview(generateButton)
    }

    private func setupConstraints() {
        constrainContentStack()
        constrainPromptTextView()
        constrainPromptPlaceholder()
        constrainModeTabsStack()
        constrainModeIndicator()
    }

    private func constrainModeTabsStack() {
        constrain(modeTabsStack, modeTabsView) { stack, container in
            stack.top == container.top
            stack.leading == container.leading
            stack.trailing == container.trailing
            stack.bottom == container.bottom - 2
            container.height == 58
        }
    }

    private func constrainModeIndicator() {
        constrain(modeIndicator, modeTabsView) { indicator, container in
            indicator.bottom == container.bottom
            indicator.leading == container.leading
            indicator.width == container.width / 2
            indicator.height == 2
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, self) { stack, superview in
            stack.edges == superview.edges
        }
    }

    private func constrainPromptTextView() {
        constrain(promptTextView, promptContainer) { textView, container in
            textView.edges == container.edges
            textView.height >= 132
        }
    }

    private func constrainPromptPlaceholder() {
        constrain(promptPlaceholder, promptContainer) { label, container in
            label.top == container.top + 14
            label.leading == container.leading + 16
            label.trailing == container.trailing - 16
        }
    }

    // MARK: - Configure

    func updateSelectedMovies(_ movies: [MovieRecommendationModels.SelectedMovieViewModel]) {
        selectedMovies = Array(movies.prefix(2))
        renderSelectedMovies()
        updateGenerateButton()
    }

    func reset() {
        selectedMovies.removeAll()
        selectedModeIndex = 0
        promptTextView.text = ""
        promptPlaceholder.isHidden = false
        updateInputMode()
        renderSelectedMovies()
    }

    // MARK: - Actions

    @objc private func modeDidChange() {
        selectedModeIndex = 1 - selectedModeIndex
        updateInputMode()
    }

    @objc private func generateTapped() {
        delegate?.didRequestRecommendation(mode: currentMode)
    }

    @objc private func selectMovieTapped(_ sender: UIButton) {
        delegate?.didRequestMovieSelection(at: sender.tag)
    }

    @objc private func removeMovieTapped(_ sender: UIButton) {
        delegate?.didRemoveMovie(at: sender.tag)
    }

    // MARK: - Helpers

    private var currentMode: MovieRecommendationMode {
        if selectedModeIndex == 0 {
            return .moment(promptTextView.text ?? "")
        }

        return .blend(
            firstMovieID: selectedMovies.first?.id ?? 0,
            secondMovieID: selectedMovies.dropFirst().first?.id ?? 0
        )
    }

    private func updateInputMode() {
        let isMoment = selectedModeIndex == 0
        promptContainer.isHidden = !isMoment
        movieSelectionStack.isHidden = isMoment
        updateModeTabs()
        updateGenerateButton()
    }

    private func updateGenerateButton() {
        let isValid: Bool
        switch selectedModeIndex {
        case 0:
            let text = promptTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            isValid = !text.isEmpty && text.count <= 500
        default:
            isValid = selectedMovies.count == 2
                && selectedMovies[0].id != selectedMovies[1].id
        }

        generateButton.isEnabled = isValid
    }

    private func renderSelectedMovies() {
        movieSelectionStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for index in 0..<2 {
            if selectedMovies.indices.contains(index) {
                let card = SelectedMovieCardView()
                card.delegate = self
                card.configure(viewModel: selectedMovies[index], index: index)
                movieSelectionStack.addArrangedSubview(card)
            } else {
                let card = EmptyMovieSelectionCardView()
                card.delegate = self
                card.configure(index: index)
                movieSelectionStack.addArrangedSubview(card)
            }
        }
    }

    private func makeModeButton(title: String, imageName: String, tag: Int) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = UIImage(systemName: imageName)
        configuration.imagePlacement = .leading
        configuration.imagePadding = 8
        configuration.baseForegroundColor = .textSecondary
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 8,
            bottom: 8,
            trailing: 8
        )

        let button = UIButton(configuration: configuration)
        button.tag = tag
        button.addTarget(self, action: #selector(modeButtonTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func modeButtonTapped(_ sender: UIButton) {
        guard sender.tag != selectedModeIndex else { return }
        selectedModeIndex = sender.tag
        updateInputMode()
    }

    private func updateModeTabs() {
        let buttons = [momentModeButton, blendModeButton]
        for (index, button) in buttons.enumerated() {
            button.configuration?.baseForegroundColor = index == selectedModeIndex
                ? .accentYellow
                : .textSecondary
        }

        modeIndicator.transform = CGAffineTransform(
            translationX: selectedModeIndex == 0 ? 0 : modeTabsView.bounds.width / 2,
            y: 0
        )
    }

}

// MARK: - UITextViewDelegate

extension MovieRecommendationInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        promptPlaceholder.isHidden = !textView.text.isEmpty
        updateGenerateButton()
    }
}

extension MovieRecommendationInputView: SelectedMovieCardViewDelegate {
    func didTapMovie(at index: Int) {
        delegate?.didRequestMovieSelection(at: index)
    }

    func didTapRemove(at index: Int) {
        delegate?.didRemoveMovie(at: index)
    }
}

extension MovieRecommendationInputView: EmptyMovieSelectionCardViewDelegate {
    func didTapSelectMovie(at index: Int) {
        delegate?.didRequestMovieSelection(at: index)
    }
}
