import Foundation

enum ChangePasswordModels {
    enum UpdatePassword {
        struct Request {
            let currentPassword: String
            let newPassword: String
            let confirmPassword: String
        }

        enum Response {
            case success
            case invalidCurrentPassword
            case passwordTooShort
            case passwordMismatch
            case error
        }

        enum ViewModel {
            case success
            case invalidCurrentPassword
            case passwordTooShort
            case passwordMismatch
            case error
        }
    }
}
