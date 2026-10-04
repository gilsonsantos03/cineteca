import Foundation

enum LegalModels {
    enum FetchLegal {
        struct Request {}

        enum Response {
            case content
        }

        enum ViewModel {
            case content(Content)

            struct Content {
                let linksSection: LinksSectionViewModel
            }
        }
    }

    enum LinkAction {
        case privacyPolicy
        case termsOfService
    }

    struct LinksSectionViewModel {
        let title: String
        let rows: [LinkRowViewModel]
    }

    struct LinkRowViewModel {
        let title: String
        let action: LinkAction
    }
}
