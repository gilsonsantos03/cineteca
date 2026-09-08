import UIKit

protocol ProfileRoutingLogic {
    func routeToEditProfile()
    func routeToAccount()
    func routeToAppearance()
    func routeToLanguage()
    func routeToLegal()
}

final class ProfileRouter: ProfileRoutingLogic {
    weak var viewController: UIViewController?
    private let userRepository: UserRepositoryProtocol
    private let appearanceRepository: AppearanceRepositoryProtocol
    private let languageRepository: LanguageRepositoryProtocol

    init(
        userRepository: UserRepositoryProtocol,
        appearanceRepository: AppearanceRepositoryProtocol,
        languageRepository: LanguageRepositoryProtocol
    ) {
        self.userRepository = userRepository
        self.appearanceRepository = appearanceRepository
        self.languageRepository = languageRepository
    }

    func routeToEditProfile() {
        let editProfileViewController = EditProfileConfigurator.resolve(userRepository: userRepository)
        viewController?.navigationController?.pushViewController(editProfileViewController, animated: true)
    }

    func routeToAccount() {
        let accountViewController = AccountConfigurator.resolve(userRepository: userRepository)
        viewController?.navigationController?.pushViewController(accountViewController, animated: true)
    }

    func routeToAppearance() {
        let appearanceViewController = AppearanceConfigurator.resolve(appearanceRepository: appearanceRepository)
        viewController?.navigationController?.pushViewController(appearanceViewController, animated: true)
    }

    func routeToLanguage() {
        let languageViewController = LanguageConfigurator.resolve(languageRepository: languageRepository)
        viewController?.navigationController?.pushViewController(languageViewController, animated: true)
    }

    func routeToLegal() {
        let legalViewController = LegalConfigurator.resolve()
        viewController?.navigationController?.pushViewController(legalViewController, animated: true)
    }
}
