import UIKit
import Cartography

final class MovieDetailsCrewView: UIStackView {

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.MovieDetailsScene.Section.crew
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        return label
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
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
        addArrangedSubview(contentStack)
    }

    // MARK: - Configure

    func configure(_ crew: [MovieDetailsModels.CrewViewModel]) {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        crew.prefix(3).forEach { member in
            let cardView = MovieDetailsCrewCardView()
            cardView.configure(viewModel: member)
            contentStack.addArrangedSubview(cardView)
        }
        isHidden = crew.isEmpty
    }
}
