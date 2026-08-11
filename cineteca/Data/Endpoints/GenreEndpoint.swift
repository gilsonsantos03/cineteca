import Foundation

enum GenreEndpoint: URLRequestBuilder, Sendable {
    case movieList

    var path: String {
        switch self {
        case .movieList: return "/genre/movie/list"
        }
    }

    var method: HTTPMethod { .get }
}
