import UIKit
import Cartography

protocol MovieReviewViewDelegate: AnyObject {
    func movieReviewViewDidRequestClose(_ view: MovieReviewView)
    func movieReviewView(
        _ view: MovieReviewView,
        didSubmit rating: Double,
        reviewText: String?
    )
}

// MARK: - Movie Review View

final class MovieReviewView: UIView {
    // MARK: Properties

    weak var delegate: MovieReviewViewDelegate?

    private let movieTitle: String
    private let metadata: String
    private let posterURL: URL?
    private let initialReviewText: String?

    private var selectedRating: Double? {
        didSet {
            updateRatingUI()
        }
    }

    // MARK: UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieDetailsScene.Review.title
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .textSecondary
        button.disableHighlighting()
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }()

    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .cardBackground
        imageView.loadImage(from: posterURL)
        return imageView
    }()

    private lazy var movieTitleLabel: UILabel = {
        let label = UILabel()
        label.text = movieTitle
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .textPrimary
        label.numberOfLines = 2
        return label
    }()

    private lazy var metadataLabel: UILabel = {
        let label = UILabel()
        label.text = metadata
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .textSecondary
        return label
    }()

    private lazy var movieInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [movieTitleLabel, metadataLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private lazy var movieInfoContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [posterImageView, movieInfoStack])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()

    private lazy var ratingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieDetailsScene.Review.yourRating
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var ratingCircleView = MovieReviewRatingCircleView()

    private lazy var ratingSlider: MovieReviewRatingSlider = {
        let slider = MovieReviewRatingSlider()
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.minimumTrackTintColor = .accentYellow
        slider.maximumTrackTintColor = .cardBackground
        slider.setThumbImage(MovieReviewRatingSlider.makeThumbImage(), for: .normal)
        slider.setThumbImage(MovieReviewRatingSlider.makeThumbImage(), for: .highlighted)
        slider.addTarget(self, action: #selector(didChangeRating(_:)), for: .valueChanged)
        return slider
    }()

    private lazy var ratingScaleView: MovieReviewRatingScaleView = {
        let view = MovieReviewRatingScaleView()
        view.delegate = self
        return view
    }()

    private lazy var ratingDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .accentYellow
        label.textAlignment = .center
        return label
    }()

    private lazy var ratingStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            ratingTitleLabel,
            ratingCircleView,
            ratingDescriptionLabel,
            ratingSlider,
            ratingScaleView
        ])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        stack.setCustomSpacing(14, after: ratingTitleLabel)
        stack.setCustomSpacing(14, after: ratingCircleView)
        return stack
    }()

    private lazy var reviewTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .cardBackground
        textView.textColor = .textPrimary
        textView.font = .systemFont(ofSize: 14)
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        textView.delegate = self
        return textView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieDetailsScene.Review.placeholder
        label.font = .systemFont(ofSize: 14)
        label.textColor = .textSecondary
        label.isUserInteractionEnabled = false
        return label
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.MovieDetailsScene.Review.submit, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.backgroundColor = .accentYellow
        button.layer.cornerRadius = 22
        button.disableHighlighting()
        button.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        return button
    }()

    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.MovieDetailsScene.Review.skip, for: .normal)
        button.setTitleColor(.textSecondary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        button.disableHighlighting()
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            movieInfoContainer,
            ratingStack,
            reviewTextView,
            submitButton,
            skipButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    // MARK: Initialization

    init(
        movieTitle: String,
        metadata: String,
        posterURL: URL?,
        currentRating: Double?,
        currentReviewText: String?
    ) {
        self.movieTitle = movieTitle
        self.metadata = metadata
        self.posterURL = posterURL
        self.initialReviewText = currentReviewText
        self.selectedRating = currentRating.map { $0.rounded() }
        super.init(frame: .zero)
        backgroundColor = .appBackground
        setupSubviews()
        setupConstraints()
        reviewTextView.text = initialReviewText
        placeholderLabel.isHidden = !(initialReviewText?.isEmpty ?? true)
        updateRatingUI()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Setup

    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(closeButton)
        addSubview(contentStack)
        reviewTextView.addSubview(placeholderLabel)
    }

    private func setupConstraints() {
        constrainTitleLabel()
        constrainCloseButton()
        constrainContentStack()
        constrainMovieInfoContainer()
        constrainRatingStack()
        constrainReviewTextView()
        constrainSubmitButton()
        constrainPlaceholderLabel()
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, self) { label, superview in
            label.top == superview.safeAreaLayoutGuide.top + 18
            label.left == superview.left + 20
        }
    }

    private func constrainCloseButton() {
        constrain(closeButton, titleLabel, self) { button, title, superview in
            button.centerY == title.centerY
            button.right == superview.right - 20
            button.width == 28
            button.height == 28
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, titleLabel, self) { stack, title, superview in
            stack.top == title.bottom + 18
            stack.left == superview.left + 20
            stack.right == superview.right - 20
        }
        constrain(contentStack, keyboardLayoutGuide) { stack, keyboardGuide in
            stack.bottom <= keyboardGuide.top - 16
        }
    }

    private func constrainMovieInfoContainer() {
        constrain(posterImageView) { poster in
            poster.width == 56
            poster.height == 80
        }
    }

    private func constrainRatingStack() {
        constrain(ratingCircleView, ratingStack) { circle, stack in
            circle.width == 136
            circle.height == 136
        }
        constrain(ratingSlider, ratingStack) { slider, stack in
            slider.width == stack.width
        }
        constrain(ratingScaleView, ratingStack) { scale, stack in
            scale.width == stack.width
        }
    }

    private func constrainReviewTextView() {
        constrain(reviewTextView) { textView in
            textView.height == 92
        }
    }

    private func constrainSubmitButton() {
        constrain(submitButton) { button in
            button.height == 46
        }
    }

    private func constrainPlaceholderLabel() {
        constrain(placeholderLabel, reviewTextView) { placeholder, textView in
            placeholder.top == textView.top + 14
            placeholder.left == textView.left + 16
            placeholder.right == textView.right - 12
        }
    }

    // MARK: Rating

    private func updateRatingUI() {
        guard let rating = selectedRating else {
            ratingCircleView.configure(rating: nil)
            ratingDescriptionLabel.text = Strings.MovieDetailsScene.Review.ratingRequired
            ratingSlider.value = 0
            ratingScaleView.configure(selectedRating: nil)
            submitButton.isEnabled = false
            submitButton.alpha = 0.5
            return
        }

        ratingCircleView.configure(rating: rating)
        ratingDescriptionLabel.text = ratingDescription(for: rating)
        ratingSlider.value = Float(rating)
        ratingScaleView.configure(selectedRating: rating)
        submitButton.isEnabled = true
        submitButton.alpha = 1
    }

    private func ratingDescription(for rating: Double) -> String {
        switch rating {
        case 0:
            return Strings.MovieDetailsScene.Review.notForMe
        case ...2:
            return Strings.MovieDetailsScene.Review.terrible
        case ...4:
            return Strings.MovieDetailsScene.Review.bad
        case ...6:
            return Strings.MovieDetailsScene.Review.okay
        case ...8:
            return Strings.MovieDetailsScene.Review.good
        case ...9:
            return Strings.MovieDetailsScene.Review.great
        default:
            return Strings.MovieDetailsScene.Review.masterpiece
        }
    }

    // MARK: Actions

    @objc private func didChangeRating(_ sender: UISlider) {
        let rating = sender.value.rounded()
        sender.value = rating
        selectedRating = Double(rating)
    }

    @objc private func didTapSubmit() {
        guard let selectedRating else { return }
        let text = reviewTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        delegate?.movieReviewView(
            self,
            didSubmit: selectedRating,
            reviewText: text.isEmpty ? nil : text
        )
    }

    @objc private func didTapClose() {
        delegate?.movieReviewViewDidRequestClose(self)
    }
}

// MARK: - UITextViewDelegate

extension MovieReviewView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

// MARK: - MovieReviewRatingScaleViewDelegate

extension MovieReviewView: MovieReviewRatingScaleViewDelegate {
    func didSelectRating(_ rating: Double) {
        selectedRating = rating
    }
}

private extension UIButton {
    func disableHighlighting() {
        adjustsImageWhenHighlighted = false
        showsTouchWhenHighlighted = false
    }
}
