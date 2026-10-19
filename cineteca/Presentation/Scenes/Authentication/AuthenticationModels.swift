import Foundation

enum AuthenticationModels {
    enum Mode {
        case signIn
        case signUp
    }

    enum Submit {
        struct Request {
            let email: String
            let username: String
            let password: String
            let mode: Mode
            let confirmation: String
        }

        enum Response {
            case success
            case error(Error)
        }

        enum ViewModel {
            case success
            case error(String)
        }
    }

    enum PasswordReset {
        struct Request {
            let email: String
        }

        enum Response {
            case success
            case error(Error)
        }

        enum ViewModel {
            case success
            case error(String)
        }
    }

    struct ProviderViewModel {
        let identifier: String
        let title: String
    }
}
