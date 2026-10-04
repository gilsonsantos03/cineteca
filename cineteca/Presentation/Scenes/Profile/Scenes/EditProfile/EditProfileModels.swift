import Foundation

enum EditProfileModels {
    enum FetchProfile {
        struct Request {}

        enum Response {
            case content(User)
            case error
        }

        enum ViewModel {
            case content(Content)
            case error

            struct Content {
                let username: String
                let displayName: String
                let bio: String
                let avatarImageName: String?
            }
        }
    }

    enum SaveProfile {
        struct Request {
            let displayName: String
            let bio: String
        }

        enum Response {
            case success
            case error
        }

        enum ViewModel {
            case success
            case error
        }
    }
}
