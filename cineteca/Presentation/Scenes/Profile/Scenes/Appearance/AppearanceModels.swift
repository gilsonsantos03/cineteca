import Foundation

enum AppearanceModels {
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
                let themeSection: ThemeSectionViewModel
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

    struct ThemeSectionViewModel {
        let title: String
        let options: [ThemeOptionViewModel]
    }

    struct ThemeOptionViewModel {
        let theme: AppTheme
        let title: String
        let isSelected: Bool
    }
}
