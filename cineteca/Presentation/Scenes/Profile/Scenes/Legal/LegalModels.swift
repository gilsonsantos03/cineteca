import Foundation

struct LegalModels {
    enum FetchLegal {
        struct Request {}

        enum Response {
            case content
        }

        enum ViewModel {
            case content(Content)

            struct Content {
                let linksSection: LegalLinksSectionViewModel
            }
        }
    }
}

enum LegalLinkAction {
    case privacyPolicy
    case termsOfService
}

struct LegalLinksSectionViewModel {
    let title: String
    let rows: [LegalLinkRowViewModel]
}

struct LegalLinkRowViewModel {
    let title: String
    let action: LegalLinkAction
}
