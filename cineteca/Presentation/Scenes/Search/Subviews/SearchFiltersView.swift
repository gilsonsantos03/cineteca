import UIKit
import Cartography

protocol SearchFiltersViewDelegate: AnyObject {
    func didUpdateFilters(_ filters: SearchFilters)
}

final class SearchFiltersView: UIView {

    // MARK: - Properties

    weak var delegate: SearchFiltersViewDelegate?

    private var filters = SearchFilters()
    private var genreOptions: [SearchGenreOptionViewModel] = []
    private var languageOptions: [SearchLanguageOptionViewModel] = []

    // MARK: - UI Components

    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 2.5
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.SearchScene.Filters.title
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .textPrimary
        return label
    }()

    private lazy var genreSectionLabel: UILabel = makeSectionLabel(text: Strings.SearchScene.Filters.genre)

    private lazy var genreCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(GenreChipCell.self, forCellWithReuseIdentifier: GenreChipCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private lazy var yearSectionLabel: UILabel = makeSectionLabel(text: Strings.SearchScene.Filters.year)

    private lazy var yearValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textSecondary
        label.textAlignment = .right
        return label
    }()

    private lazy var yearHeaderRow: UIStackView = {
        let row = UIStackView(arrangedSubviews: [yearSectionLabel, yearValueLabel])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        return row
    }()

    private lazy var yearRangeSliderView = SearchYearRangeSliderView()

    private lazy var ratingSectionLabel: UILabel = makeSectionLabel(text: Strings.SearchScene.Filters.minRating)

    private lazy var ratingPickerView = SearchRatingPickerView()

    private lazy var languageSectionLabel: UILabel = makeSectionLabel(text: Strings.SearchScene.Filters.language)

    private lazy var languageButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .cardBackground
        button.layer.cornerRadius = 12
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.setTitleColor(.textPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(languageTapped), for: .touchUpInside)
        return button
    }()

    private lazy var languageChevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        imageView.tintColor = .textSecondary
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            genreSectionLabel,
            genreCollectionView,
            yearHeaderRow,
            yearRangeSliderView,
            ratingSectionLabel,
            ratingPickerView,
            languageSectionLabel,
            languageButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(24, after: titleLabel)
        stack.setCustomSpacing(8, after: genreSectionLabel)
        stack.setCustomSpacing(20, after: genreCollectionView)
        stack.setCustomSpacing(8, after: yearHeaderRow)
        stack.setCustomSpacing(20, after: yearRangeSliderView)
        stack.setCustomSpacing(8, after: ratingSectionLabel)
        stack.setCustomSpacing(20, after: ratingPickerView)
        stack.setCustomSpacing(8, after: languageSectionLabel)
        return stack
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .cardBackground
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        ratingPickerView.delegate = self
        yearRangeSliderView.delegate = self
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(handleView)
        addSubview(scrollView)
        scrollView.addSubview(contentStack)
        languageButton.addSubview(languageChevronImageView)
    }

    private func setupConstraints() {
        constrainHandleView()
        constrainScrollView()
        constrainContentStack()
        constrainLanguageChevronImageView()
        constrainLanguageButton()
        constrainGenreCollectionView()
    }

    private func constrainHandleView() {
        constrain(handleView, self) { handle, superview in
            handle.top == superview.top + 10
            handle.centerX == superview.centerX
            handle.width == 40
            handle.height == 5
        }
    }

    private func constrainScrollView() {
        constrain(scrollView, handleView, self) { scrollView, handle, superview in
            scrollView.top == handle.bottom + 16
            scrollView.left == superview.left
            scrollView.right == superview.right
            scrollView.bottom == superview.bottom - 24
        }
    }

    private func constrainContentStack() {
        constrain(contentStack, scrollView) { stack, scrollView in
            stack.top == scrollView.top
            stack.bottom == scrollView.bottom
            stack.left == scrollView.left + 20
            stack.right == scrollView.right - 20
            stack.width == scrollView.width - 40
        }
    }

    private func constrainLanguageChevronImageView() {
        constrain(languageChevronImageView, languageButton) { imageView, button in
            imageView.centerY == button.centerY
            imageView.right == button.right - 16
            imageView.width == 14
            imageView.height == 14
        }
    }

    private func constrainLanguageButton() {
        constrain(languageButton) { button in
            button.height == 48
        }
    }

    private func constrainGenreCollectionView() {
        constrain(genreCollectionView) { collectionView in
            collectionView.height >= 80
        }
    }

    // MARK: - Configure

    func configure(viewModel: SearchFiltersViewModel) {
        genreOptions = viewModel.genres
        languageOptions = viewModel.languages

        filters.yearFrom = viewModel.yearFrom
        filters.yearTo = viewModel.yearTo
        filters.minRating = viewModel.minRating
        filters.selectedGenreIds = Set(viewModel.genres.filter(\.isSelected).map(\.id))
        filters.languageCode = viewModel.selectedLanguageCode

        yearRangeSliderView.configure(
            minYear: viewModel.minYear,
            maxYear: viewModel.maxYear,
            yearFrom: viewModel.yearFrom,
            yearTo: viewModel.yearTo
        )

        ratingPickerView.configure(rating: viewModel.minRating)
        updateYearLabel()
        updateLanguageButton()
        genreCollectionView.reloadData()
    }

    // MARK: - Actions

    @objc private func languageTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for option in languageOptions {
            alert.addAction(UIAlertAction(title: option.name, style: .default) { [weak self] _ in
                guard let self else { return }
                self.filters.languageCode = option.code
                self.languageOptions = self.languageOptions.map {
                    SearchLanguageOptionViewModel(code: $0.code, name: $0.name, isSelected: $0.code == option.code)
                }
                self.updateLanguageButton()
                self.notifyFiltersChanged()
            })
        }
        alert.addAction(UIAlertAction(title: Strings.SearchScene.Filters.cancel, style: .cancel))
        parentViewController?.present(alert, animated: true)
    }

    // MARK: - Helpers

    private func makeSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .textSecondary
        return label
    }

    private func updateYearLabel() {
        yearValueLabel.text = "\(filters.yearFrom) – \(filters.yearTo)"
    }

    private func updateLanguageButton() {
        let selectedName = languageOptions.first(where: \.isSelected)?.name
            ?? Strings.SearchScene.Filters.Language.all
        languageButton.setTitle(selectedName, for: .normal)
    }

    private func notifyFiltersChanged() {
        delegate?.didUpdateFilters(filters)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension SearchFiltersView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        genreOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GenreChipCell.reuseId,
            for: indexPath
        ) as! GenreChipCell
        let option = genreOptions[indexPath.item]
        cell.configure(title: option.name, isSelected: option.isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let option = genreOptions[indexPath.item]
        if filters.selectedGenreIds.contains(option.id) {
            filters.selectedGenreIds.remove(option.id)
        } else {
            filters.selectedGenreIds.insert(option.id)
        }
        genreOptions[indexPath.item] = SearchGenreOptionViewModel(
            id: option.id,
            name: option.name,
            isSelected: filters.selectedGenreIds.contains(option.id)
        )
        collectionView.reloadItems(at: [indexPath])
        notifyFiltersChanged()
    }
}

// MARK: - SearchYearRangeSliderViewDelegate

extension SearchFiltersView: SearchYearRangeSliderViewDelegate {
    func didChangeYearRange(from yearFrom: Int, to yearTo: Int) {
        filters.yearFrom = yearFrom
        filters.yearTo = yearTo
        updateYearLabel()
        notifyFiltersChanged()
    }
}

// MARK: - SearchRatingPickerViewDelegate

extension SearchFiltersView: SearchRatingPickerViewDelegate {
    func didSelectRating(_ rating: Int) {
        filters.minRating = rating
        notifyFiltersChanged()
    }
}

// MARK: - LeftAlignedCollectionViewFlowLayout

private final class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1

        for attribute in attributes where attribute.representedElementCategory == .cell {
            if attribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            attribute.frame.origin.x = leftMargin
            leftMargin += attribute.frame.width + minimumInteritemSpacing
            maxY = max(attribute.frame.maxY, maxY)
        }

        return attributes
    }
}

// MARK: - UIView parentViewController helper

private extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let viewController = current as? UIViewController {
                return viewController
            }
            responder = current.next
        }
        return nil
    }
}
