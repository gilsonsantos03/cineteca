import Foundation

protocol LanguageBusinessLogic {
    func fetchLanguage(request: LanguageModels.FetchLanguage.Request)
    func previewLanguage(request: LanguageModels.PreviewLanguage.Request)
    func applyLanguage(request: LanguageModels.ApplyLanguage.Request)
}

final class LanguageInteractor {
    private let presenter: LanguagePresentationLogic
    private let languageRepository: LanguageRepositoryProtocol
    private var savedLanguage: AppLanguage = .enUS
    private var pendingLanguage: AppLanguage = .enUS

    init(presenter: LanguagePresentationLogic, languageRepository: LanguageRepositoryProtocol) {
        self.presenter = presenter
        self.languageRepository = languageRepository
    }
}

extension LanguageInteractor: LanguageBusinessLogic {
    func fetchLanguage(request: LanguageModels.FetchLanguage.Request) {
        savedLanguage = languageRepository.fetchSelectedLanguage()
        pendingLanguage = savedLanguage
        presenter.presentFetchLanguage(response: .content(savedLanguage: savedLanguage, pendingLanguage: pendingLanguage))
    }

    func previewLanguage(request: LanguageModels.PreviewLanguage.Request) {
        pendingLanguage = request.language
        presenter.presentPreviewLanguage(response: .content(savedLanguage: savedLanguage, pendingLanguage: pendingLanguage))
    }

    func applyLanguage(request: LanguageModels.ApplyLanguage.Request) {
        languageRepository.saveSelectedLanguage(pendingLanguage)
        savedLanguage = pendingLanguage
        presenter.presentApplyLanguage(response: .success(pendingLanguage))
    }
}
