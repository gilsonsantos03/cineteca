import UIKit

protocol ProfileRoutingLogic {
    func routeToEditProfile()
    func routeToMyReviews()
    func routeToAccount()
    func routeToAppearance()
    func routeToLanguage()
    func routeToLegal()
}

final class ProfileRouter: ProfileRoutingLogic {
    weak var viewController: UIViewController?
    private let editProfileBuilder: EditProfileBuilding
    private let myReviewsBuilder: MyReviewsBuilding
    private let accountBuilder: AccountBuilding
    private let appearanceBuilder: AppearanceBuilding
    private let languageBuilder: LanguageBuilding
    private let legalBuilder: LegalBuilding

    init(
        editProfileBuilder: EditProfileBuilding,
        myReviewsBuilder: MyReviewsBuilding,
        accountBuilder: AccountBuilding,
        appearanceBuilder: AppearanceBuilding,
        languageBuilder: LanguageBuilding,
        legalBuilder: LegalBuilding
    ) {
        self.editProfileBuilder = editProfileBuilder
        self.myReviewsBuilder = myReviewsBuilder
        self.accountBuilder = accountBuilder
        self.appearanceBuilder = appearanceBuilder
        self.languageBuilder = languageBuilder
        self.legalBuilder = legalBuilder
    }

    func routeToEditProfile() {
        let editProfileViewController = editProfileBuilder.makeEditProfile()
        viewController?.navigationController?.pushViewController(editProfileViewController, animated: true)
    }

    func routeToAccount() {
        let accountViewController = accountBuilder.makeAccount()
        viewController?.navigationController?.pushViewController(accountViewController, animated: true)
    }

    func routeToMyReviews() {
        let myReviewsViewController = myReviewsBuilder.makeMyReviews()
        viewController?.navigationController?.pushViewController(myReviewsViewController, animated: true)
    }

    func routeToAppearance() {
        let appearanceViewController = appearanceBuilder.makeAppearance()
        viewController?.navigationController?.pushViewController(appearanceViewController, animated: true)
    }

    func routeToLanguage() {
        let languageViewController = languageBuilder.makeLanguage()
        viewController?.navigationController?.pushViewController(languageViewController, animated: true)
    }

    func routeToLegal() {
        let legalViewController = legalBuilder.makeLegal()
        viewController?.navigationController?.pushViewController(legalViewController, animated: true)
    }
}
