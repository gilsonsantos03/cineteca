import Foundation

struct HomeModels {
    enum FetchContent {
        struct Request {}

        struct Response {
            let featured: Movie
            let nowPlaying: [Movie]
            let trending: [Movie]
            let topRated: [Movie]
        }

        struct ViewModel {
            let featured: FeaturedViewModel
            let nowPlaying: [MovieCardViewModel]
            let trending: [MovieCardViewModel]
            let topRated: [MovieCardViewModel]
        }
    }

    enum ErrorState {
        struct ViewModel {}
    }
}

struct FeaturedViewModel {
    let title: String
    let year: String
    let rating: String
    let genres: [String]
    let backdropURL: URL?
}

struct MovieCardViewModel {
    let id: Int
    let title: String
    let rating: String
    let posterURL: URL?
    let isTrending: Bool
}
