import UIKit
import Cartography

protocol SelectedMovieCardViewDelegate: AnyObject {
    func didTapMovie(at index: Int)
    func didTapRemove(at index: Int)
}

final class SelectedMovieCardView: UIView {
    weak var delegate: SelectedMovieCardViewDelegate?
    private var index = 0

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textPrimary
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var removeButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "xmark.circle.fill")
        configuration.baseForegroundColor = .white
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 4,
            bottom: 8,
            trailing: 4
        )

        let button = UIButton(configuration: configuration)
        button.accessibilityIdentifier = "movieRecommendation.removeMovie"
        button.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        backgroundColor = .cardBackground
        layer.cornerRadius = 20
        clipsToBounds = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieTapped)))
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(removeButton)
        setupConstraints()
    }

    private func setupConstraints() {
        constrainImageView()
        constrainTitleLabel()
        constrainRemoveButton()
    }

    private func constrainImageView() {
        constrain(imageView, self) { imageView, container in
            imageView.edges == container.edges
            container.height == 300
        }
    }

    private func constrainTitleLabel() {
        constrain(titleLabel, self) { title, container in
            title.leading == container.leading + 8
            title.trailing == container.trailing - 8
            title.bottom == container.bottom - 12
        }
    }

    private func constrainRemoveButton() {
        constrain(removeButton, self) { button, container in
            button.top == container.top
            button.trailing == container.trailing
            button.width == 44
            button.height == 44
        }
    }

    func configure(
        viewModel: MovieRecommendationModels.SelectedMovieViewModel,
        index: Int
    ) {
        self.index = index
        imageView.loadImage(from: viewModel.backdropURL)
        titleLabel.text = viewModel.title
    }

    @objc private func movieTapped() {
        delegate?.didTapMovie(at: index)
    }

    @objc private func removeTapped() {
        delegate?.didTapRemove(at: index)
    }
}
