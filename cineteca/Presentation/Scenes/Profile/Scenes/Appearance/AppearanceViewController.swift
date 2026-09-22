import UIKit

protocol AppearanceDisplayLogic: AnyObject {
    func displayFetchAppearance(viewModel: AppearanceModels.FetchAppearance.ViewModel)
    func displayPreviewTheme(viewModel: AppearanceModels.PreviewTheme.ViewModel)
    func displayApplyAppearance(viewModel: AppearanceModels.ApplyAppearance.ViewModel)
}

final class AppearanceViewController: UIViewController {
    private let customView: AppearanceView
    private let interactor: AppearanceBusinessLogic
    private let router: AppearanceRoutingLogic

    init(
        customView: AppearanceView,
        interactor: AppearanceBusinessLogic,
        router: AppearanceRoutingLogic
    ) {
        self.customView = customView
        self.interactor = interactor
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
        interactor.fetchAppearance(request: .init())
    }
}

extension AppearanceViewController: AppearanceDisplayLogic {
    func displayFetchAppearance(viewModel: AppearanceModels.FetchAppearance.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        }
    }

    func displayPreviewTheme(viewModel: AppearanceModels.PreviewTheme.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        }
    }

    func displayApplyAppearance(viewModel: AppearanceModels.ApplyAppearance.ViewModel) {
        customView.setApplying(false)

        switch viewModel {
        case .success(let theme):
            ThemeManager.apply(theme)
            router.routeBack()
        }
    }
}

extension AppearanceViewController: AppearanceViewDelegate {
    func didTapBack() {
        router.routeBack()
    }

    func didTapCancel() {
        router.routeBack()
    }

    func didSelectTheme(_ theme: AppTheme) {
        interactor.previewTheme(request: .init(theme: theme))
    }

    func didTapApplyChanges() {
        customView.setApplying(true)
        interactor.applyAppearance(request: .init())
    }
}
