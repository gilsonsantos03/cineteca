import Foundation

enum LanguageModels {
    enum FetchLanguage {
        struct Request {}

        enum Response {
            case content(savedLanguage: AppLanguage, pendingLanguage: AppLanguage)
        }

        enum ViewModel {
            case content(Content)

            struct Content {
                let savedLanguage: AppLanguage
                let pendingLanguage: AppLanguage
                let languageSection: OptionSectionViewModel
                let isSaveEnabled: Bool
            }
        }
    }

    enum PreviewLanguage {
        struct Request {
            let language: AppLanguage
        }

        enum Response {
            case content(savedLanguage: AppLanguage, pendingLanguage: AppLanguage)
        }

        enum ViewModel {
            case content(LanguageModels.FetchLanguage.ViewModel.Content)
        }
    }

    enum ApplyLanguage {
        struct Request {}

        enum Response {
            case success(AppLanguage)
        }

        enum ViewModel {
            case success(AppLanguage)
        }
    }

    struct OptionSectionViewModel {
        let title: String
        let options: [OptionViewModel]
    }

    struct OptionViewModel {
        let language: AppLanguage
        let title: String
        let isSelected: Bool
    }
}
