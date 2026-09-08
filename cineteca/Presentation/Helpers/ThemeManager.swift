import UIKit

enum ThemeManager {
    static let themeDidChangeNotification = Notification.Name("ThemeManager.themeDidChange")

    static func apply(_ theme: AppTheme) {
        activeWindows.forEach { window in
            switch theme {
            case .dark:
                window.overrideUserInterfaceStyle = .dark
            case .light:
                window.overrideUserInterfaceStyle = .light
            case .system:
                window.overrideUserInterfaceStyle = .unspecified
            }
        }

        NotificationCenter.default.post(name: themeDidChangeNotification, object: theme)
    }

    private static var activeWindows: [UIWindow] {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
    }
}
