import Foundation

final class AppearanceRepository: AppearanceRepositoryProtocol {
    private let defaults: UserDefaults
    private let themeKey = "app_selected_theme"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func fetchSelectedTheme() -> AppTheme {
        guard
            let rawValue = defaults.string(forKey: themeKey),
            let theme = AppTheme(rawValue: rawValue)
        else {
            return .dark
        }
        return theme
    }

    func saveSelectedTheme(_ theme: AppTheme) {
        defaults.set(theme.rawValue, forKey: themeKey)
    }
}
