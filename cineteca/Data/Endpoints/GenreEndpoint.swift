import Foundation

enum GenreEndpoint: URLRequestBuilder, Sendable {
    case movieList(language: String)

    var path: String {
        switch self {
        case .movieList: return "/genre/movie/list"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem] {
        switch self {
        case let .movieList(language):
            return [URLQueryItem(name: "language", value: language)]
        }
    }
}
