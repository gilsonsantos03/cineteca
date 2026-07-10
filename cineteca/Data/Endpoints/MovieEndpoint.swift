import Foundation

enum MovieEndpoint: URLRequestBuilder, Sendable {
    case nowPlaying(language: String)
    case trending(language: String)
    case topRated(language: String)
    case featured(language: String)

    var path: String {
        switch self {
        case .nowPlaying: return "/movie/now_playing"
        case .trending: return "/trending/movie/week"
        case .topRated: return "/movie/top_rated"
        case .featured: return "/movie/popular"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "language", value: language),
         URLQueryItem(name: "page", value: "1")]
    }

    private var language: String {
        switch self {
        case let .nowPlaying(language),
             let .trending(language),
             let .topRated(language),
             let .featured(language):
            return language
        }
    }
}
