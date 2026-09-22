import UIKit

protocol LanguageDisplayLogic: AnyObject {
    func displayFetchLanguage(viewModel: LanguageModels.FetchLanguage.ViewModel)
    func displayPreviewLanguage(viewModel: LanguageModels.PreviewLanguage.ViewModel)
    func displayApplyLanguage(viewModel: LanguageModels.ApplyLanguage.ViewModel)
}

final class LanguageViewController: UIViewController {
    private let customView: LanguageView
    private let interactor: LanguageBusinessLogic
    private let router: LanguageRoutingLogic

    init(
        customView: LanguageView,
        interactor: LanguageBusinessLogic,
        router: LanguageRoutingLogic
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
        interactor.fetchLanguage(request: .init())
    }
}

extension LanguageViewController: LanguageDisplayLogic {
    func displayFetchLanguage(viewModel: LanguageModels.FetchLanguage.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        }
    }

    func displayPreviewLanguage(viewModel: LanguageModels.PreviewLanguage.ViewModel) {
        switch viewModel {
        case let .content(content):
            customView.showContent(content: content)
        }
    }

    func displayApplyLanguage(viewModel: LanguageModels.ApplyLanguage.ViewModel) {
        customView.setSaving(false)

        switch viewModel {
        case .success(let language):
            LanguageManager.apply(language)
            router.routeAfterApply()
        }
    }
}

extension LanguageViewController: LanguageViewDelegate {
    func didTapBack() {
        router.routeBack()
    }

    func didTapCancel() {
        router.routeBack()
    }

    func didSelectLanguage(_ language: AppLanguage) {
        interactor.previewLanguage(request: .init(language: language))
    }

    func didTapSaveChanges() {
        customView.setSaving(true)
        interactor.applyLanguage(request: .init())
    }
}
