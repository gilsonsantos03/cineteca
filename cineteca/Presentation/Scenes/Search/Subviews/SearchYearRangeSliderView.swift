import UIKit
import Cartography

protocol SearchYearRangeSliderViewDelegate: AnyObject {
    func didChangeYearRange(from yearFrom: Int, to yearTo: Int)
}

final class SearchYearRangeSliderView: UIView {

    // MARK: - Properties

    weak var delegate: SearchYearRangeSliderViewDelegate?

    private let thumbSize: CGFloat = 24
    private let trackHeight: CGFloat = 4

    private var minYear = 1990
    private var maxYear = Calendar.current.component(.year, from: Date())
    private var yearFrom = 1990
    private var yearTo = Calendar.current.component(.year, from: Date())

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

    private lazy var minThumbView = makeThumbView()
    private lazy var maxThumbView = makeThumbView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        updateThumbPositions(notifyDelegate: false)
    }

    // MARK: - Setup

    private func setup() {
        setupGestures()
        setupSubviews()
        setupConstraints()
    }

    private func setupGestures() {
        minThumbView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleMinPan(_:))))
        maxThumbView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleMaxPan(_:))))
    }

    private func setupSubviews() {
        addSubview(trackView)
        addSubview(selectedTrackView)
        addSubview(minThumbView)
        addSubview(maxThumbView)
    }

    private func setupConstraints() {
        constrainTrackView()
        constrainSelf()
    }

    private func constrainTrackView() {
        constrain(trackView, self) { track, superview in
            track.centerY == superview.centerY
            track.left == superview.left
            track.right == superview.right
            track.height == trackHeight
        }
    }

    private func constrainSelf() {
        constrain(self) { superview in
            superview.height == 32
        }
    }

    // MARK: - Configure

    func configure(minYear: Int, maxYear: Int, yearFrom: Int, yearTo: Int) {
        self.minYear = minYear
        self.maxYear = maxYear
        self.yearFrom = clamp(yearFrom, min: minYear, max: yearTo)
        self.yearTo = clamp(yearTo, min: self.yearFrom, max: maxYear)
        setNeedsLayout()
    }

    // MARK: - Actions

    @objc private func handleMinPan(_ gesture: UIPanGestureRecognizer) {
        let trackBounds = trackView.bounds
        guard trackBounds.width > 0 else { return }

        let translation = gesture.translation(in: trackView)
        gesture.setTranslation(.zero, in: trackView)

        let currentX = xPosition(for: yearFrom, in: trackBounds.width)
        let newX = clamp(currentX + translation.x, min: 0, max: xPosition(for: yearTo, in: trackBounds.width))
        yearFrom = year(for: newX, in: trackBounds.width)
        updateThumbPositions(notifyDelegate: gesture.state == .changed || gesture.state == .ended)
    }

    @objc private func handleMaxPan(_ gesture: UIPanGestureRecognizer) {
        let trackBounds = trackView.bounds
        guard trackBounds.width > 0 else { return }

        let translation = gesture.translation(in: trackView)
        gesture.setTranslation(.zero, in: trackView)

        let currentX = xPosition(for: yearTo, in: trackBounds.width)
        let newX = clamp(
            currentX + translation.x,
            min: xPosition(for: yearFrom, in: trackBounds.width),
            max: trackBounds.width
        )
        yearTo = year(for: newX, in: trackBounds.width)
        updateThumbPositions(notifyDelegate: gesture.state == .changed || gesture.state == .ended)
    }

    // MARK: - Helpers

    private func makeThumbView() -> UIView {
        let thumbView = UIView()
        thumbView.backgroundColor = .accentYellow
        thumbView.layer.cornerRadius = thumbSize / 2
        thumbView.isUserInteractionEnabled = true
        return thumbView
    }

    private func updateThumbPositions(notifyDelegate: Bool) {
        let trackWidth = trackView.bounds.width
        guard trackWidth > 0 else { return }

        let minX = xPosition(for: yearFrom, in: trackWidth)
        let maxX = xPosition(for: yearTo, in: trackWidth)

        positionThumb(minThumbView, at: minX)
        positionThumb(maxThumbView, at: maxX)
        updateSelectedTrack(minX: minX, maxX: maxX)

        if notifyDelegate {
            delegate?.didChangeYearRange(from: yearFrom, to: yearTo)
        }
    }

    private func positionThumb(_ thumbView: UIView, at xPosition: CGFloat) {
        thumbView.frame = CGRect(
            x: trackView.frame.minX + xPosition - thumbSize / 2,
            y: bounds.midY - thumbSize / 2,
            width: thumbSize,
            height: thumbSize
        )
    }

    private func updateSelectedTrack(minX: CGFloat, maxX: CGFloat) {
        selectedTrackView.frame = CGRect(
            x: trackView.frame.minX + minX,
            y: trackView.frame.midY - trackHeight / 2,
            width: max(maxX - minX, 0),
            height: trackHeight
        )
    }

    private func xPosition(for year: Int, in trackWidth: CGFloat) -> CGFloat {
        guard maxYear > minYear else { return 0 }
        let progress = CGFloat(year - minYear) / CGFloat(maxYear - minYear)
        return progress * trackWidth
    }

    private func year(for xPosition: CGFloat, in trackWidth: CGFloat) -> Int {
        guard trackWidth > 0, maxYear > minYear else { return minYear }
        let progress = clamp(xPosition / trackWidth, min: 0, max: 1)
        let year = minYear + Int(round(progress * CGFloat(maxYear - minYear)))
        return clamp(year, min: minYear, max: maxYear)
    }

    private func clamp<T: Comparable>(_ value: T, min minValue: T, max maxValue: T) -> T {
        Swift.min(Swift.max(value, minValue), maxValue)
    }
}
