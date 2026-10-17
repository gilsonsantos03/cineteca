import UIKit
import Cartography

protocol SearchRatingPickerViewDelegate: AnyObject {
    func didSelectRating(_ rating: Int)
}

final class SearchRatingPickerView: UIView {

    // MARK: - Properties

    weak var delegate: SearchRatingPickerViewDelegate?

    private let thumbSize: CGFloat = 24
    private let trackHeight: CGFloat = 4
    private let minRating = 0
    private let maxRating = 10

    private var selectedRating = 0

    // MARK: - UI Components

    private lazy var trackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        view.layer.cornerRadius = trackHeight / 2
        return view
    }()

    private lazy var selectedTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = .accentYellow
        view.layer.cornerRadius = trackHeight / 2
        return view
    }()

    private lazy var thumbView: UIView = {
        let view = UIView()
        view.backgroundColor = .accentYellow
        view.layer.cornerRadius = thumbSize / 2
        view.isUserInteractionEnabled = true
        return view
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        updateThumbPosition(notifyDelegate: false)
    }

    // MARK: - Setup

    private func setup() {
        setupGestures()
        setupSubviews()
        setupConstraints()
    }

    private func setupGestures() {
        thumbView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    private func setupSubviews() {
        addSubview(trackView)
        addSubview(selectedTrackView)
        addSubview(thumbView)
    }

    private func setupConstraints() {
        constrainTrackView()
        constrainSelf()
    }

    private func constrainTrackView() {
        let horizontalInset = thumbSize / 2
        constrain(trackView, self) { track, superview in
            track.centerY == superview.centerY
            track.left == superview.left + horizontalInset
            track.right == superview.right - horizontalInset
            track.height == trackHeight
        }
    }

    private func constrainSelf() {
        constrain(self) { superview in
            superview.height == 32
        }
    }

    // MARK: - Configure

    func configure(rating: Int) {
        selectedRating = clamp(rating)
        setNeedsLayout()
    }

    // MARK: - Actions

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let trackBounds = trackView.bounds
        guard trackBounds.width > 0 else { return }

        let translation = gesture.translation(in: trackView)
        gesture.setTranslation(.zero, in: trackView)

        let currentX = xPosition(for: selectedRating, in: trackBounds.width)
        let newX = clamp(currentX + translation.x, min: 0, max: trackBounds.width)
        applyRating(rating(for: newX, in: trackBounds.width), notify: gesture.state == .changed || gesture.state == .ended)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let trackBounds = trackView.bounds
        guard trackBounds.width > 0 else { return }
        let location = gesture.location(in: trackView)
        applyRating(rating(for: location.x, in: trackBounds.width), notify: true)
    }

    // MARK: - Helpers

    private func applyRating(_ rating: Int, notify: Bool) {
        let clamped = clamp(rating)
        selectedRating = clamped
        updateThumbPosition(notifyDelegate: notify)
    }

    private func updateThumbPosition(notifyDelegate: Bool) {
        let trackWidth = trackView.bounds.width
        guard trackWidth > 0 else { return }

        let x = xPosition(for: selectedRating, in: trackWidth)
        thumbView.frame = CGRect(
            x: trackView.frame.minX + x - thumbSize / 2,
            y: bounds.midY - thumbSize / 2,
            width: thumbSize,
            height: thumbSize
        )
        selectedTrackView.frame = CGRect(
            x: trackView.frame.minX,
            y: trackView.frame.midY - trackHeight / 2,
            width: max(x, 0),
            height: trackHeight
        )

        if notifyDelegate {
            delegate?.didSelectRating(selectedRating)
        }
    }

    private func xPosition(for rating: Int, in trackWidth: CGFloat) -> CGFloat {
        guard maxRating > minRating else { return 0 }
        let progress = CGFloat(rating - minRating) / CGFloat(maxRating - minRating)
        return progress * trackWidth
    }

    private func rating(for xPosition: CGFloat, in trackWidth: CGFloat) -> Int {
        guard trackWidth > 0, maxRating > minRating else { return minRating }
        let progress = clamp(xPosition / trackWidth, min: 0, max: 1)
        let rating = minRating + Int(round(progress * CGFloat(maxRating - minRating)))
        return clamp(rating)
    }

    private func clamp(_ rating: Int) -> Int {
        Swift.min(Swift.max(rating, minRating), maxRating)
    }

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, minValue), maxValue)
    }
}
