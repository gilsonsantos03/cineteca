import UIKit

@MainActor
protocol MovieDetailsBuilding {
    func makeMovieDetails(movieId: Int) -> UIViewController
}

@MainActor
protocol MovieCatalogBuilding {
    func makeMovieCatalog(category: MovieCollectionCategory, title: String) -> UIViewController
}

@MainActor
protocol EditProfileBuilding {
    func makeEditProfile() -> UIViewController
}

@MainActor
protocol SearchBuilding {
    func makeSearch(
        selectionBehavior: SearchModels.SelectionBehavior,
        selectionDelegate: SearchSelectionDelegate?
    ) -> UIViewController
}

@MainActor
protocol MyReviewsBuilding {
    func makeMyReviews() -> UIViewController
}

@MainActor
protocol ListsBuilding {
    func makeLists() -> UIViewController
}

@MainActor
protocol AccountBuilding {
    func makeAccount() -> UIViewController
}

@MainActor
protocol AppearanceBuilding {
    func makeAppearance() -> UIViewController
}

@MainActor
protocol LanguageBuilding {
    func makeLanguage() -> UIViewController
}

@MainActor
protocol LegalBuilding {
    func makeLegal() -> UIViewController
}

@MainActor
protocol LegalDocumentBuilding {
    func makeLegalDocument(documentType: LegalDocumentType) -> UIViewController
}
