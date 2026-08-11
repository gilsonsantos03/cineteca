import UIKit

final class MovieDetailsOverviewView: UIStackView {

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieDetailsScene.Section.synopsis
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        return label
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .textSecondary
        label.numberOfLines = 3
        return label
    }()

    private lazy var readMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.MovieDetailsScene.Action.readMore, for: .normal)
        button.setTitleColor(.accentYellow, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: #selector(didTapReadMore), for: .touchUpInside)
        return button
    }()

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
        axis = .vertical
        spacing = 10
        addArrangedSubview(titleLabel)
        addArrangedSubview(textLabel)
        addArrangedSubview(readMoreButton)
    }

    // MARK: - Configure

    func configure(text: String) {
        textLabel.text = text
        readMoreButton.isHidden = text.isEmpty
    }

    // MARK: - Actions

    @objc private func didTapReadMore() {
        textLabel.numberOfLines = 0
        readMoreButton.isHidden = true
    }
}
