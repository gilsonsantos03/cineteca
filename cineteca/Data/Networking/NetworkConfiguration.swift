import Foundation

struct NetworkConfiguration: Sendable {
    let baseURL: URL
    let defaultHeaders: [String: String]

    init(baseURL: URL, defaultHeaders: [String: String] = [:]) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
    }
}
