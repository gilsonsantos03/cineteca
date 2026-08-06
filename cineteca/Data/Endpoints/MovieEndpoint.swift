import Foundation

enum MovieEndpoint: URLRequestBuilder, Sendable {
    case nowPlaying(language: String)
    case trending(language: String)
    case topRated(language: String)
    case featured(language: String)
    case videos(movieId: Int, language: String)

    var path: String {
        switch self {
        case .nowPlaying: return "/movie/now_playing"
        case .trending: return "/trending/movie/week"
        case .topRated: return "/movie/top_rated"
        case .featured: return "/movie/popular"
        case let .videos(movieId, _): return "/movie/\(movieId)/videos"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem] {
        switch self {
        case .videos:
            return [URLQueryItem(name: "language", value: language)]
        default:
            return [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "page", value: "1")
            ]
        }
    }

    private var language: String {
        switch self {
        case let .nowPlaying(language),
             let .trending(language),
             let .topRated(language),
             let .featured(language),
             let .videos(_, language):
            return language
        }
    }
}
