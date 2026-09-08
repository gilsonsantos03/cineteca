import Foundation

struct AppearanceModels {
    enum FetchAppearance {
        struct Request {}

        enum Response {
            case content(savedTheme: AppTheme, pendingTheme: AppTheme)
        }

        enum ViewModel {
            case content(Content)

            struct Content {
                let savedTheme: AppTheme
                let pendingTheme: AppTheme
                let themeSection: AppearanceThemeSectionViewModel
                let isApplyEnabled: Bool
            }
        }
    }

    enum PreviewTheme {
        struct Request {
            let theme: AppTheme
        }

        enum Response {
            case content(savedTheme: AppTheme, pendingTheme: AppTheme)
        }

        enum ViewModel {
            case content(AppearanceModels.FetchAppearance.ViewModel.Content)
        }
    }

    enum ApplyAppearance {
        struct Request {}

        enum Response {
            case success(AppTheme)
        }

        enum ViewModel {
            case success(AppTheme)
        }
    }
}

struct AppearanceThemeSectionViewModel {
    let title: String
    let options: [AppearanceThemeOptionViewModel]
}

struct AppearanceThemeOptionViewModel {
    let theme: AppTheme
    let title: String
    let isSelected: Bool
}
