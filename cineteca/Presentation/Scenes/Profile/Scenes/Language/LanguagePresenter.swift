import Foundation

protocol LanguagePresentationLogic {
    func presentFetchLanguage(response: LanguageModels.FetchLanguage.Response)
    func presentPreviewLanguage(response: LanguageModels.PreviewLanguage.Response)
    func presentApplyLanguage(response: LanguageModels.ApplyLanguage.Response)
}

protocol LanguageDisplayLogic: AnyObject {
    func displayFetchLanguage(viewModel: LanguageModels.FetchLanguage.ViewModel)
    func displayPreviewLanguage(viewModel: LanguageModels.PreviewLanguage.ViewModel)
    func displayApplyLanguage(viewModel: LanguageModels.ApplyLanguage.ViewModel)
}

final class LanguagePresenter {
    weak var view: LanguageDisplayLogic?
}

extension LanguagePresenter: LanguagePresentationLogic {
    func presentFetchLanguage(response: LanguageModels.FetchLanguage.Response) {
        switch response {
        case let .content(savedLanguage, pendingLanguage):
            view?.displayFetchLanguage(
                viewModel: .content(makeContent(savedLanguage: savedLanguage, pendingLanguage: pendingLanguage))
            )
        }
    }

    func presentPreviewLanguage(response: LanguageModels.PreviewLanguage.Response) {
        switch response {
        case let .content(savedLanguage, pendingLanguage):
            view?.displayPreviewLanguage(
                viewModel: .content(makeContent(savedLanguage: savedLanguage, pendingLanguage: pendingLanguage))
            )
        }
    }

    func presentApplyLanguage(response: LanguageModels.ApplyLanguage.Response) {
        switch response {
        case .success(let language):
            view?.displayApplyLanguage(viewModel: .success(language))
        }
    }

    private func makeContent(
        savedLanguage: AppLanguage,
        pendingLanguage: AppLanguage
    ) -> LanguageModels.FetchLanguage.ViewModel.Content {
        LanguageModels.FetchLanguage.ViewModel.Content(
            savedLanguage: savedLanguage,
            pendingLanguage: pendingLanguage,
            languageSection: LanguageOptionSectionViewModel(
                title: Strings.LanguageScene.Section.appLanguage,
                options: AppLanguage.allCases.map { language in
                    LanguageOptionViewModel(
                        language: language,
                        title: language.displayName,
                        isSelected: language == pendingLanguage
                    )
                }
            ),
            isSaveEnabled: pendingLanguage != savedLanguage
        )
    }
}
