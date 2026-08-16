import Foundation

enum MovieEndpoint: URLRequestBuilder, Sendable {
    case nowPlaying
    case trending
    case topRated
    case featured
    case search(query: String)
    case discover(filters: SearchFilters, query: String?)
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
        case .search: return "/search/movie"
        case .discover: return "/discover/movie"
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
        case let .search(query):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: "1")
            ]
        case let .discover(filters, query):
            return discoverQueryItems(filters: filters, query: query)
        case .videos, .details, .credits, .watchProviders, .releaseDates:
            return []
        }
    }

    private func discoverQueryItems(filters: SearchFilters, query: String?) -> [URLQueryItem] {
        var items = [URLQueryItem(name: "page", value: "1")]

        if !filters.selectedGenreIds.isEmpty {
            let genreValue = filters.selectedGenreIds.map(String.init).sorted().joined(separator: ",")
            items.append(URLQueryItem(name: "with_genres", value: genreValue))
        }

        items.append(URLQueryItem(name: "primary_release_date.gte", value: "\(filters.yearFrom)-01-01"))
        items.append(URLQueryItem(name: "primary_release_date.lte", value: "\(filters.yearTo)-12-31"))

        if filters.minRating > 0 {
            let minVoteAverage = Double(filters.minRating) * 2.0
            items.append(URLQueryItem(name: "vote_average.gte", value: String(format: "%.1f", minVoteAverage)))
        }

        if let languageCode = filters.languageCode, !languageCode.isEmpty {
            items.append(URLQueryItem(name: "with_original_language", value: languageCode))
        }

        if let query, !query.isEmpty {
            items.append(URLQueryItem(name: "with_text_query", value: query))
        }

        return items
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
