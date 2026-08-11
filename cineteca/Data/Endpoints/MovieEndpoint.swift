import Foundation

enum MovieEndpoint: URLRequestBuilder, Sendable {
    case nowPlaying
    case trending
    case topRated
    case featured
    case details(movieId: Int)
    case credits(movieId: Int)
    case videos(movieId: Int)
    case similar(movieId: Int)
    case watchProviders(movieId: Int)
    case releaseDates(movieId: Int)

    var path: String {
        switch self {
        case .nowPlaying: return "/movie/now_playing"
        case .trending: return "/trending/movie/week"
        case .topRated: return "/movie/top_rated"
        case .featured: return "/movie/popular"
        case let .details(movieId): return "/movie/\(movieId)"
        case let .credits(movieId): return "/movie/\(movieId)/credits"
        case let .videos(movieId): return "/movie/\(movieId)/videos"
        case let .similar(movieId): return "/movie/\(movieId)/similar"
        case let .watchProviders(movieId): return "/movie/\(movieId)/watch/providers"
        case let .releaseDates(movieId): return "/movie/\(movieId)/release_dates"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem] {
        switch self {
        case .similar, .nowPlaying, .trending, .topRated, .featured:
            return [URLQueryItem(name: "page", value: "1")]
        case .videos, .details, .credits, .watchProviders, .releaseDates:
            return []
        }
    }

    var requiresLanguage: Bool {
        switch self {
        case .watchProviders, .releaseDates:
            return false
        default:
            return true
        }
    }
}
