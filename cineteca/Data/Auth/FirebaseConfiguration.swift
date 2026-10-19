import FirebaseCore
import Foundation

enum FirebaseConfiguration {
    static var isConfigured: Bool {
        FirebaseApp.app() != nil
    }

    static func configureIfPossible() {
        guard FirebaseApp.app() == nil else { return }
        guard
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: path)
        else {
            assertionFailure("Add GoogleService-Info.plist to configure Firebase.")
            return
        }

        FirebaseApp.configure(options: options)
    }
}
