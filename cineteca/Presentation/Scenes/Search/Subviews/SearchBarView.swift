import UIKit
import Cartography

protocol SearchBarViewDelegate: AnyObject {
    func didChangeText(_ text: String)
    func didSubmitQuery(_ query: String)
    func didTapFilter()
}

final class SearchBarView: UIView {

    // MARK: - Properties

    weak var delegate: SearchBarViewDelegate?

    // MARK: - UI Components

    private lazy var searchIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .textSecondary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .textPrimary
        textField.tintColor = .accentYellow
        textField.attributedPlaceholder = NSAttributedString(
            string: Strings.SearchScene.SearchBar.placeholder,
            attributes: [.foregroundColor: UIColor.textSecondary]
        )
        textField.returnKeyType = .search
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.delegate = self
        return textField
    }()

    private lazy var searchFieldContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .cardBackground
        container.layer.cornerRadius = 12
        return container
    }()

    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        button.tintColor = .textPrimary
        button.backgroundColor = .cardBackground
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        return button
    }()

    private lazy var contentRow: UIStackView = {
        let row = UIStackView(arrangedSubviews: [searchFieldContainer, filterButton])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .fill
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
        backgroundColor = .appBackground
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(contentRow)
        searchFieldContainer.addSubview(searchIconImageView)
        searchFieldContainer.addSubview(searchTextField)
    }

    private func setupConstraints() {
        constrainContentRow()
        constrainSearchIconImageView()
        constrainSearchTextField()
        constrainFilterButton()
    }

    private func constrainContentRow() {
        constrain(contentRow, self) { row, superview in
            row.top == superview.top + 8
            row.bottom == superview.bottom - 8
            row.left == superview.left + 20
            row.right == superview.right - 20
        }
    }

    private func constrainSearchIconImageView() {
        constrain(searchIconImageView, searchFieldContainer) { imageView, container in
            imageView.centerY == container.centerY
            imageView.left == container.left + 14
            imageView.width == 18
            imageView.height == 18
        }
    }

    private func constrainSearchTextField() {
        constrain(searchTextField, searchIconImageView, searchFieldContainer) { textField, imageView, container in
            textField.centerY == container.centerY
            textField.left == imageView.right + 10
            textField.right == container.right - 14
            textField.top == container.top + 12
            textField.bottom == container.bottom - 12
        }
    }

    private func constrainFilterButton() {
        constrain(filterButton) { button in
            button.width == 48
        }
    }

    // MARK: - Actions

    @objc private func textDidChange() {
        delegate?.didChangeText(searchTextField.text ?? "")
    }

    @objc private func filterTapped() {
        delegate?.didTapFilter()
    }
}

// MARK: - UITextFieldDelegate

extension SearchBarView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.didSubmitQuery(textField.text ?? "")
        return true
    }
}
