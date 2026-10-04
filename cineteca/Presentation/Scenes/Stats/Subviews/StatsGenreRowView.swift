import UIKit
import Cartography

final class StatsGenreRowView: UIView {

    // MARK: - Properties

    private var progress: Double = 0
    private var progressConstraint: NSLayoutConstraint?

    // MARK: - UI Components

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .textPrimary
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var trackView: UIView = {
        let view = UIView()
        view.backgroundColor = .surfaceOverlay
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    private lazy var fillView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    private lazy var percentageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textSecondary
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
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
        updateProgressWidth()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(nameLabel)
        addSubview(trackView)
        trackView.addSubview(fillView)
        addSubview(percentageLabel)
    }

    private func setupConstraints() {
        constrainSelf()
        constrainNameLabel()
        constrainPercentageLabel()
        constrainTrackView()
        constrainFillView()
    }

    private func constrainSelf() {
        constrain(self) { view in
            view.height == 18
        }
    }

    private func constrainNameLabel() {
        constrain(nameLabel, self) { label, superview in
            label.left == superview.left
            label.centerY == superview.centerY
            label.width == 72
        }
    }

    private func constrainPercentageLabel() {
        constrain(percentageLabel, self) { label, superview in
            label.right == superview.right
            label.centerY == superview.centerY
            label.width == 40
        }
    }

    private func constrainTrackView() {
        constrain(trackView, nameLabel, percentageLabel, self) { track, name, percentage, superview in
            track.left == name.right + 12
            track.right == percentage.left - 12
            track.centerY == superview.centerY
            track.height == 8
        }
    }

    private func constrainFillView() {
        constrain(fillView, trackView) { fill, track in
            fill.top == track.top
            fill.bottom == track.bottom
            fill.left == track.left
        }
        let constraint = fillView.widthAnchor.constraint(equalToConstant: 0)
        constraint.isActive = true
        progressConstraint = constraint
    }

    // MARK: - Configure

    func configure(viewModel: StatsModels.GenreRowViewModel) {
        nameLabel.text = viewModel.name
        percentageLabel.text = viewModel.percentageText
        fillView.backgroundColor = color(for: viewModel.tone)
        progress = viewModel.progress
        setNeedsLayout()
    }

    // MARK: - Helpers

    private func updateProgressWidth() {
        let width = trackView.bounds.width * CGFloat(progress)
        progressConstraint?.constant = progress > 0 ? max(width, 8) : 0
    }

    private func color(for tone: StatsModels.GenreTone) -> UIColor {
        switch tone {
        case .accent:
            return .accentYellow
        case .pink:
            return UIColor(red: 0.93, green: 0.35, blue: 0.55, alpha: 1)
        case .cyan:
            return UIColor(red: 0.25, green: 0.78, blue: 0.86, alpha: 1)
        case .muted:
            return .textSecondary
        }
    }
}
