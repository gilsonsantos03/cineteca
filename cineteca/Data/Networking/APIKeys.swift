import Foundation

enum APIKeys {
    static var apiKey: String? {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let key = plist["API_KEY"] as? String else {
            return nil
        }
        return key
    }
}
