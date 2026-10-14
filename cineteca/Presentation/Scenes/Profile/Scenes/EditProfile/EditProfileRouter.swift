import UIKit

protocol EditProfileRoutingLogic {
    func routeBack()
    func routeToMovieSearch(delegate: SearchSelectionDelegate)
}

final class EditProfileRouter {
    weak var viewController: UIViewController?
    private let searchBuilder: SearchBuilding

    init(searchBuilder: SearchBuilding) {
        self.searchBuilder = searchBuilder
    }
}

extension EditProfileRouter: EditProfileRoutingLogic {
    func routeBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func routeToMovieSearch(delegate: SearchSelectionDelegate) {
        let searchViewController = searchBuilder.makeSearch(
            selectionBehavior: .selectMovie,
            selectionDelegate: delegate
        )
        let navigationController = UINavigationController(rootViewController: searchViewController)
        navigationController.modalPresentationStyle = .pageSheet
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        viewController?.present(navigationController, animated: true)
    }
}
