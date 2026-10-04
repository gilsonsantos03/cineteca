import Foundation

enum AccountModels {
    enum FetchAccount {
        struct Request {}

        enum Response {
            case content(User)
            case error
        }

        enum ViewModel {
            case content(Content)
            case error

            struct Content {
                let profileCard: ProfileCardViewModel
                let profileSection: SectionViewModel
                let securitySection: SectionViewModel
                let dangerSection: SectionViewModel
            }
        }
    }

    enum RowAction: Equatable {
        case changePassword
        case deleteAccount
    }

    struct ProfileCardViewModel {
        let username: String
        let email: String
        let avatarImageName: String?
    }

    struct SectionViewModel {
        let title: String
        let rows: [RowViewModel]
    }

    enum RowViewModel {
        case value(title: String, value: String)
        case navigation(title: String, action: RowAction)
        case danger(title: String, action: RowAction)
    }
}
