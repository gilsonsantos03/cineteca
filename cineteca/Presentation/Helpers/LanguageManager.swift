import Foundation

enum LanguageManager {
    static var localizedBundle: Bundle = .main

    static func bootstrap(selectedLanguage: AppLanguage) {
        localizedBundle = AppLanguage.bundle(for: selectedLanguage)
    }

    static func apply(_ language: AppLanguage) {
        localizedBundle = AppLanguage.bundle(for: language)
    }
}
