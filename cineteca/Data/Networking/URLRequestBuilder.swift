import Alamofire
import Foundation

protocol URLRequestBuilder: URLRequestConvertible {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: [String: String] { get }
}
