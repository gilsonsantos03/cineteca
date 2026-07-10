import Foundation

protocol LocaleProviderProtocol: Sendable {
    var apiLanguage: String { get }
}

struct LocaleProvider: LocaleProviderProtocol {
    private static let supportedLanguages: Set<String> = ["pt-BR", "en-US"]
    private static let fallbackLanguage = "en-US"

    var apiLanguage: String {
        let language = Locale.current.language.languageCode?.identifier ?? ""
        let region = Locale.current.region?.identifier ?? ""
        let tag = region.isEmpty ? language : "\(language)-\(region)"

        if Self.supportedLanguages.contains(tag) {
            return tag
        }
        if language == "pt" {
            return "pt-BR"
        }
        return Self.fallbackLanguage
    }
}
