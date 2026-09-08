import Foundation

enum Localization {
    static func string(_ key: String, comment: String = "") -> String {
        NSLocalizedString(key, bundle: LanguageManager.localizedBundle, comment: comment)
    }
}
