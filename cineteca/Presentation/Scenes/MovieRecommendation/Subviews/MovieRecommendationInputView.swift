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

    private lazy var modeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [
            Strings.MovieRecommendationScene.momentMode,
            Strings.MovieRecommendationScene.blendMode
        ])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(modeDidChange), for: .valueChanged)
        return control
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
        stack.axis = .vertical
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
        contentStack.addArrangedSubview(introLabel)
        contentStack.addArrangedSubview(modeControl)
        contentStack.addArrangedSubview(promptContainer)
        contentStack.addArrangedSubview(movieSelectionStack)
        contentStack.addArrangedSubview(generateButton)
    }

    private func setupConstraints() {
        constrainContentStack()
        constrainPromptTextView()
        constrainPromptPlaceholder()
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
            label.left == container.left + 16
            label.right == container.right - 16
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
        modeControl.selectedSegmentIndex = 0
        promptTextView.text = ""
        promptPlaceholder.isHidden = false
        updateInputMode()
        renderSelectedMovies()
    }

    // MARK: - Actions

    @objc private func modeDidChange() {
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
        if modeControl.selectedSegmentIndex == 0 {
            return .moment(promptTextView.text ?? "")
        }

        return .blend(
            firstMovieID: selectedMovies.first?.id ?? 0,
            secondMovieID: selectedMovies.dropFirst().first?.id ?? 0
        )
    }

    private func updateInputMode() {
        let isMoment = modeControl.selectedSegmentIndex == 0
        promptContainer.isHidden = !isMoment
        movieSelectionStack.isHidden = isMoment
        updateGenerateButton()
    }

    private func updateGenerateButton() {
        let isValid: Bool
        switch modeControl.selectedSegmentIndex {
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
                movieSelectionStack.addArrangedSubview(
                    makeSelectedMovieRow(selectedMovies[index], at: index)
                )
            } else {
                movieSelectionStack.addArrangedSubview(makeAddMovieButton(index: index))
            }
        }
    }

    private func makeAddMovieButton(index: Int) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = Strings.MovieRecommendationScene.selectMovie
        configuration.image = UIImage(systemName: "plus")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 8
        configuration.titleAlignment = .leading
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        configuration.cornerStyle = .medium
        configuration.baseBackgroundColor = .cardBackground
        configuration.baseForegroundColor = .textPrimary

        let button = UIButton(configuration: configuration)
        button.tag = index
        button.addTarget(self, action: #selector(selectMovieTapped(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = "movieRecommendation.selectMovie.\(index)"
        button.heightAnchor.constraint(equalToConstant: 58).isActive = true
        return button
    }

    private func makeSelectedMovieRow(
        _ movie: MovieRecommendationModels.SelectedMovieViewModel,
        at index: Int
    ) -> UIView {
        let container = UIView()
        container.backgroundColor = .cardBackground
        container.layer.cornerRadius = 14

        let titleLabel = UILabel()
        titleLabel.text = movie.title
        titleLabel.textColor = .textPrimary
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 2

        let changeButton = makeMovieActionButton(
            imageName: "arrow.triangle.2.circlepath",
            accessibilityIdentifier: "movieRecommendation.changeMovie.\(index)"
        )
        changeButton.addTarget(self, action: #selector(selectMovieTapped(_:)), for: .touchUpInside)
        changeButton.tag = index

        let removeButton = makeMovieActionButton(
            imageName: "xmark.circle.fill",
            accessibilityIdentifier: "movieRecommendation.removeMovie.\(index)"
        )
        removeButton.tintColor = .textSecondary
        removeButton.addTarget(self, action: #selector(removeMovieTapped(_:)), for: .touchUpInside)
        removeButton.tag = index

        let actionStack = UIStackView(arrangedSubviews: [changeButton, removeButton])
        actionStack.axis = .horizontal
        actionStack.spacing = 12

        container.addSubview(titleLabel)
        container.addSubview(actionStack)
        constrain(titleLabel, actionStack, container) { titleLabel, actionStack, container in
            titleLabel.top == container.top + 8
            titleLabel.left == container.left + 16
            titleLabel.bottom == container.bottom - 8
            titleLabel.right == actionStack.left - 10
            actionStack.centerY == container.centerY
            actionStack.right == container.right - 12
        }
        container.heightAnchor.constraint(greaterThanOrEqualToConstant: 58).isActive = true
        return container
    }

    private func makeMovieActionButton(
        imageName: String,
        accessibilityIdentifier: String
    ) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: imageName)
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 4,
            bottom: 8,
            trailing: 4
        )
        configuration.baseForegroundColor = .accentYellow

        let button = UIButton(configuration: configuration)
        button.accessibilityIdentifier = accessibilityIdentifier
        button.widthAnchor.constraint(equalToConstant: 32).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return button
    }
}

// MARK: - UITextViewDelegate

extension MovieRecommendationInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        promptPlaceholder.isHidden = !textView.text.isEmpty
        updateGenerateButton()
    }
}
