import UIKit

final class LegalDocumentViewController: UIViewController {
    private let customView: LegalDocumentView
    private let router: LegalDocumentRoutingLogic

    init(
        customView: LegalDocumentView,
        router: LegalDocumentRoutingLogic
    ) {
        self.customView = customView
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        customView.delegate = self
    }
}

extension LegalDocumentViewController: LegalDocumentViewDelegate {
    func didTapBack() {
        router.routeBack()
    }
}
