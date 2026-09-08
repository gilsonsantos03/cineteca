import UIKit

protocol ProfileRoutingLogic {
    func routeToEditProfile()
}

final class ProfileRouter: ProfileRoutingLogic {
    weak var viewController: UIViewController?
    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    func routeToEditProfile() {
        let editProfileViewController = EditProfileConfigurator.resolve(userRepository: userRepository)
        viewController?.navigationController?.pushViewController(editProfileViewController, animated: true)
    }
}
