import Foundation

enum AccountRowAction: Equatable {
    case changePassword
    case deleteAccount
}

struct AccountModels {
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
                let profileCard: AccountProfileCardViewModel
                let profileSection: AccountSectionViewModel
                let securitySection: AccountSectionViewModel
                let dangerSection: AccountSectionViewModel
            }
        }
    }
}

struct AccountProfileCardViewModel {
    let username: String
    let email: String
    let avatarImageName: String?
}

struct AccountSectionViewModel {
    let title: String
    let rows: [AccountRowViewModel]
}

enum AccountRowViewModel {
    case value(title: String, value: String)
    case navigation(title: String, action: AccountRowAction)
    case danger(title: String, action: AccountRowAction)
}
