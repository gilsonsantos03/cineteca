import Foundation

extension URLRequestBuilder {
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    var body: (any Encodable & Sendable)? { nil }
}
