import Foundation

final class LanguageRepository: LanguageRepositoryProtocol {
    private let defaults: UserDefaults
    private let languageKey = "app_selected_language"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func fetchSelectedLanguage() -> AppLanguage {
        guard
            let rawValue = defaults.string(forKey: languageKey),
            let language = AppLanguage(rawValue: rawValue)
        else {
            return AppLanguage.fromSystemLocale()
        }
        return language
    }

    func saveSelectedLanguage(_ language: AppLanguage) {
        defaults.set(language.rawValue, forKey: languageKey)
        defaults.set([language.localeIdentifier], forKey: "AppleLanguages")
    }
}
