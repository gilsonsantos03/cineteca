import Foundation

protocol URLRequestBuilder: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: (any Encodable & Sendable)? { get }
}
