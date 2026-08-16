import UIKit
import Cartography

protocol SearchRatingPickerViewDelegate: AnyObject {
    func didSelectRating(_ rating: Int)
}

final class SearchRatingPickerView: UIView {

    // MARK: - Properties

    weak var delegate: SearchRatingPickerViewDelegate?

    private var selectedRating = 0
    private var starButtons: [UIButton] = []

    // MARK: - UI Components

    private lazy var starsRow: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fillEqually
        return row
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        setupStarButtons()
        setupSubviews()
        setupConstraints()
    }

    private func setupStarButtons() {
        for index in 1...5 {
            let button = UIButton(type: .system)
            button.tag = index
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starButtons.append(button)
            starsRow.addArrangedSubview(button)
        }
    }

    private func setupSubviews() {
        addSubview(starsRow)
    }

    private func setupConstraints() {
        constrainStarsRow()
    }

    private func constrainStarsRow() {
        constrain(starsRow, self) { row, superview in
            row.top == superview.top
            row.bottom == superview.bottom
            row.left == superview.left
            row.right == superview.right
            row.height == 32
        }
    }

    // MARK: - Configure

    func configure(rating: Int) {
        selectedRating = rating
        updateStars()
    }

    // MARK: - Actions

    @objc private func starTapped(_ sender: UIButton) {
        let rating = sender.tag
        selectedRating = selectedRating == rating ? 0 : rating
        updateStars()
        delegate?.didSelectRating(selectedRating)
    }

    // MARK: - Helpers

    private func updateStars() {
        for button in starButtons {
            let isFilled = button.tag <= selectedRating
            let imageName = isFilled ? "star.fill" : "star"
            button.setImage(UIImage(systemName: imageName), for: .normal)
            button.tintColor = .accentYellow
        }
    }
}
