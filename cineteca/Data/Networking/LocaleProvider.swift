import Foundation

protocol LocaleProviderProtocol: Sendable {
    var apiLanguage: String { get }
}

struct LocaleProvider: LocaleProviderProtocol {
    private let languageRepository: LanguageRepositoryProtocol

    init(languageRepository: LanguageRepositoryProtocol = LanguageRepository()) {
        self.languageRepository = languageRepository
    }

    var apiLanguage: String {
        languageRepository.fetchSelectedLanguage().apiLanguageCode
    }
}
