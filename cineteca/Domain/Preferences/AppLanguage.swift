import Foundation

enum AppLanguage: String, CaseIterable, Sendable {
    case ptBR = "pt-BR"
    case enUS = "en-US"

    var displayName: String {
        switch self {
        case .ptBR:
            "Português (Brasil)"
        case .enUS:
            "English (US)"
        }
    }

    var localeIdentifier: String { rawValue }

    var apiLanguageCode: String {
        switch self {
        case .ptBR:
            "pt-BR"
        case .enUS:
            "en-US"
        }
    }

    var bundleResourceName: String {
        switch self {
        case .ptBR:
            "pt-BR"
        case .enUS:
            "en"
        }
    }

    static func fromSystemLocale() -> AppLanguage {
        let preferred = Locale.preferredLanguages.first ?? AppLanguage.enUS.localeIdentifier
        if preferred.hasPrefix("pt") { return .ptBR }
        return .enUS
    }

    static func bundle(for language: AppLanguage) -> Bundle {
        if let path = Bundle.main.path(forResource: language.bundleResourceName, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }

        if let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }

        return .main
    }
}
