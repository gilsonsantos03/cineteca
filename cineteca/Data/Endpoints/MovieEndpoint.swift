import Foundation

enum MovieEndpoint: URLRequestBuilder, Sendable {
    case nowPlaying(language: String)
    case trending(language: String)
    case topRated(language: String)
    case featured(language: String)
    case details(movieId: Int, language: String)
    case credits(movieId: Int, language: String)
    case videos(movieId: Int, language: String)
    case similar(movieId: Int, language: String)
    case watchProviders(movieId: Int)
    case releaseDates(movieId: Int)

    var path: String {
        switch self {
        case .nowPlaying: return "/movie/now_playing"
        case .trending: return "/trending/movie/week"
        case .topRated: return "/movie/top_rated"
        case .featured: return "/movie/popular"
        case let .details(movieId, _): return "/movie/\(movieId)"
        case let .credits(movieId, _): return "/movie/\(movieId)/credits"
        case let .videos(movieId, _): return "/movie/\(movieId)/videos"
        case let .similar(movieId, _): return "/movie/\(movieId)/similar"
        case let .watchProviders(movieId): return "/movie/\(movieId)/watch/providers"
        case let .releaseDates(movieId): return "/movie/\(movieId)/release_dates"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem] {
        switch self {
        case .videos, .details, .credits:
            return [URLQueryItem(name: "language", value: language)]
        case .similar:
            return [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "page", value: "1")
            ]
        case .watchProviders, .releaseDates:
            return []
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
             let .details(_, language),
             let .credits(_, language),
             let .videos(_, language),
             let .similar(_, language):
            return language
        case .watchProviders, .releaseDates:
            return ""
        }
    }
}
