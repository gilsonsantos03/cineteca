import UIKit

protocol MovieDetailsBuilding {
    func makeMovieDetails(movieId: Int) -> UIViewController
}

protocol EditProfileBuilding {
    func makeEditProfile() -> UIViewController
}

protocol AccountBuilding {
    func makeAccount() -> UIViewController
}

protocol AppearanceBuilding {
    func makeAppearance() -> UIViewController
}

protocol LanguageBuilding {
    func makeLanguage() -> UIViewController
}

protocol LegalBuilding {
    func makeLegal() -> UIViewController
}

protocol ChangePasswordBuilding {
    func makeChangePassword() -> UIViewController
}

protocol LegalDocumentBuilding {
    func makeLegalDocument(documentType: LegalDocumentType) -> UIViewController
}
