import FirebaseCore
import Foundation

enum FirebaseConfiguration {
    private static var configuredGoogleAppID: String?

    static var isConfigured: Bool {
        configuredGoogleAppID != nil
    }

    @discardableResult
    static func configureIfPossible() -> Bool {
        guard !isConfigured else { return true }
        guard
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: path)
        else {
            assertionFailure("Add GoogleService-Info.plist to configure Firebase.")
            return false
        }

        FirebaseApp.configure(options: options)
        guard
            let configuredApp = FirebaseApp.app(),
            configuredApp.options.googleAppID == options.googleAppID,
            configuredApp.options.projectID == options.projectID
        else {
            assertionFailure("Firebase was configured with unexpected project settings.")
            return false
        }

        configuredGoogleAppID = configuredApp.options.googleAppID
        return true
    }
}
