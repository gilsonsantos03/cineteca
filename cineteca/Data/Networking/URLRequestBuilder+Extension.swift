import Alamofire
import Foundation

struct NetworkConfiguration {
    let baseURL: URL
    let defaultHeaders: [String: String]

    static let shared = NetworkConfiguration(
        baseURL: URL(string: "")!,
        defaultHeaders: [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    )
}

extension URLRequestBuilder {

    var configuration: NetworkConfiguration {
        .shared
    }

    var requestURL: URL {
        configuration.baseURL.appendingPathComponent(path)
    }

    var mergedHeaders: [String: String] {
        configuration.defaultHeaders.merging(headers) { _, new in new }
    }

    var parameterEncoding: Alamofire.ParameterEncoding {
        method == .get ? URLEncoding.default : JSONEncoding.default
    }

    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue

        mergedHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return try parameterEncoding.encode(request, with: parameters)
    }
}

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
