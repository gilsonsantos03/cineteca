import UIKit

protocol MovieReviewSheetBuilding: AnyObject {
    @discardableResult
    func present(
        from viewController: UIViewController,
        configuration: MovieReviewViewController.Configuration,
        delegate: MovieReviewViewControllerDelegate
    ) -> MovieReviewViewController
}

final class MovieReviewSheetFactory: MovieReviewSheetBuilding {
    @discardableResult
    func present(
        from viewController: UIViewController,
        configuration: MovieReviewViewController.Configuration,
        delegate: MovieReviewViewControllerDelegate
    ) -> MovieReviewViewController {
        let reviewViewController = MovieReviewViewController(configuration: configuration)
        reviewViewController.delegate = delegate

        let reviewDetent = UISheetPresentationController.Detent.Identifier("review")
        reviewViewController.sheetPresentationController?.detents = [
            .custom(identifier: reviewDetent) { context in
                min(680, context.maximumDetentValue - 24)
            }
        ]
        reviewViewController.sheetPresentationController?.selectedDetentIdentifier = reviewDetent
        reviewViewController.sheetPresentationController?.prefersGrabberVisible = true
        reviewViewController.sheetPresentationController?.preferredCornerRadius = 24

        viewController.present(reviewViewController, animated: true)
        return reviewViewController
    }
}
