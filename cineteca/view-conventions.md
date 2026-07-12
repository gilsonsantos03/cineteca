---
ai_read_when: Read this when writing or reviewing any UIKit `UIView` / `UICollectionViewCell` / `UITableViewCell` subclass in the app — before creating a new scene view or refactoring an existing one.
---

# View Conventions

UIKit view baseline for the cineteca app: how each `UIView` subclass is organized, how subviews are declared and laid out, and when to split a scene's view into multiple files. Layout uses [Cartography](https://github.com/robb/Cartography) — this doc assumes that.

- **Goal:** every view file reads the same way, so any view is scannable at a glance.
- **Use when:** creating a new view, extracting a subview, or reviewing a PR that touches `Presentation/`.
- **Reference implementation:** [cineteca/Presentation/Scenes/Home/](cineteca/Presentation/Scenes/Home/) and its [Subviews/](cineteca/Presentation/Scenes/Home/Subviews/) folder.

## Class Structure

Every `UIView` / `UICollectionViewCell` / `UITableViewCell` subclass follows the same section order, marked with `// MARK: -`. Skip a section only if it is empty for that view.

```swift
final class SomeView: UIView {

    // MARK: - Properties          ← stored non-UI state (optional)

    // MARK: - UI Components       ← every subview, one `private lazy var` each

    // MARK: - Initialization      ← init(frame:) + required init?(coder:)

    // MARK: - Lifecycle           ← layoutSubviews, traitCollectionDidChange, etc. (optional)

    // MARK: - Setup               ← setup() → setupSubviews() → setupConstraints() → constrain*()

    // MARK: - Configure           ← func configure(viewModel:) — public entry to bind data

    // MARK: - Actions             ← @objc handlers (optional)

    // MARK: - Helpers             ← private helpers used by Configure/Setup (optional)
}

// MARK: - Protocol Conformance   ← UICollectionViewDataSource, delegates, etc. via extensions
extension SomeView: UICollectionViewDataSource { ... }
```

**Rules:**

- One class per file. Cells live in their own file even when only used by one view.
- Protocol conformances (`UICollectionViewDataSource`, custom delegates, `SomeViewProtocol`) go in `extension`s at the bottom of the same file, each preceded by a `// MARK: -`.
- No `// MARK:` without the hyphen — always `// MARK: - Section`.

## Setup Pipeline

The `setup()` method is the single wiring entry point called from `init(frame:)`. It never contains layout code directly — it delegates.

```swift
private func setup() {
    backgroundColor = .appBackground
    setupSubviews()
    setupConstraints()
}

private func setupSubviews() {
    addSubview(titleLabel)
    addSubview(imageView)
    // one addSubview per line, in the order they appear visually / in the hierarchy
}

private func setupConstraints() {
    constrainTitleLabel()
    constrainImageView()
    // no layout code here — only calls to constrain*() methods
}

private func constrainTitleLabel() {
    constrain(titleLabel, self) { label, superview in
        label.top == superview.top + 16
        label.left == superview.left + 20
    }
}

private func constrainImageView() {
    constrain(imageView, titleLabel) { imageView, label in
        imageView.top == label.bottom + 12
        imageView.left == label.left
    }
}
```

**Rules:**

- One `constrain<ComponentName>()` per subview. Name it after the property it constrains, not after what it does (`constrainTitleLabel`, not `constrainHeader`).
- `setupConstraints()` is a flat list of calls, nothing else. No conditionals, no inline `constrain(...)` blocks.
- If the view constrains itself (e.g. `self.height == 72`), that goes in `constrainSelf()`.
- Extra one-off setup (gradient layer, gesture recognizer) gets its own `setup<Something>()` method called from `setup()`.

## Naming & Style

### Properties

- **Always `private lazy var`** for UI components — never `private let`. `lazy` allows any component to reference `self` or other properties during initialization (e.g., a label whose text comes from `sectionTitle`).
- **Full names**, no abbreviations. Even in the closure that builds the component:

    ```swift
    // ✅
    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    // ❌
    private lazy var posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    ```

- Property naming follows the type of the component:

    | Type | Suffix | Example |
    |---|---|---|
    | `UILabel` | `Label` | `titleLabel`, `ratingLabel` |
    | `UIButton` | `Button` | `watchTrailerButton`, `seeAllButton` |
    | `UIImageView` | `ImageView` | `posterImageView`, `starImageView` |
    | `UITextField` | `TextField` | `nameTextField` |
    | `UIStackView` | `Stack` or `Row` | `movieInfoStack`, `ratingYearRow` |
    | `UICollectionView` | `CollectionView` | `collectionView` |
    | `UIView` (container) | `View` or `Container` | `imdbBadgeView`, `trendingBadgeView` |

### Init

- Always pair `override init(frame: CGRect) { super.init(frame: frame); setup() }` with `required init?(coder: NSCoder) { nil }` — never `fatalError()`.

### Constraint closures

- Closure parameters get **full descriptive names**, matching what they hold: `label, superview`, `imageView, container`, `stack, row`. Never `l, s` or `v, p`.
- Use a **single space** between operands and operators — no vertical alignment padding:

    ```swift
    // ✅
    label.top == container.top + 8
    label.bottom == container.bottom - 8

    // ❌
    label.top    == container.top    + 8
    label.bottom == container.bottom - 8
    ```

### Colors

- Reference colors via the Asset Catalog extensions (`.appBackground`, `.cardBackground`, `.accentYellow`, `.textSecondary`). Never hardcode `UIColor(red:...)`.

## When to Split into Its Own File

Every scene starts with a single `<Scene>View.swift`. Extract a subview into its own file under `<Scene>/Subviews/` when **any** of these is true:

- **It's a cell.** `UICollectionViewCell` and `UITableViewCell` subclasses always live in their own file.
- **It has its own state.** Anything with stored properties beyond its subviews (selection index, backing array, delegate) belongs in its own file.
- **It has non-trivial layout.** ~4+ subviews, or multiple `constrain*()` methods.
- **It's reused across the scene.** If the parent instantiates the same view type more than once (e.g. `MovieSectionView(title: "Now Playing")` used three times), extract it.
- **The parent file is passing ~200 lines.** Split before it becomes hard to navigate.

If none of these apply, keep the subview inline as a `private lazy var` in the parent view — no need to extract prematurely.

### File layout

```
Presentation/Scenes/<Scene>/
├── <Scene>Configurator.swift
├── <Scene>Interactor.swift
├── <Scene>Models.swift
├── <Scene>Presenter.swift
├── <Scene>Router.swift
├── <Scene>View.swift              ← only the root scene view
├── <Scene>ViewController.swift
└── Subviews/                      ← everything the scene view composes
    ├── SomeSectionView.swift
    ├── SomeCardCell.swift
    └── SomeBadgeView.swift
```

The extracted subview follows the same class structure and setup pipeline as the root scene view — the split is purely about file boundaries, not a different pattern.

## Configure

Views are **display-only**. They accept a view model and bind it — no business logic, no data fetching.

```swift
func configure(viewModel: FeaturedViewModel) {
    backdropImageView.loadImage(from: viewModel.backdropURL)
    titleLabel.text = viewModel.title
    imdbRatingLabel.text = viewModel.rating
}
```

- One public `configure(viewModel:)` per view. If the view has to expose more than one setter, that is a signal the parent should own the state instead.
- View models come from the scene's `Presenter` (see [architecture.md](architecture.md) — VIP section). Views never reach into repositories, services, or `HomeModels.Response`.

## Cell Reuse

Cells register and dequeue via a static `reuseId` matching the class name:

```swift
final class MovieCardCell: UICollectionViewCell {
    static let reuseId = "MovieCardCell"
    // ...
}

// registration
collectionView.register(MovieCardCell.self, forCellWithReuseIdentifier: MovieCardCell.reuseId)

// dequeue
let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCardCell.reuseId, for: indexPath) as! MovieCardCell
```

Implement `prepareForReuse()` whenever the cell holds resettable state (images, timers, cancellables):

```swift
override func prepareForReuse() {
    super.prepareForReuse()
    posterImageView.image = nil
}
```
