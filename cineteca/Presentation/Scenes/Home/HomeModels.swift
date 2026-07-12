import Foundation

struct HomeModels {
    enum FetchContent {
        struct Request {}

        struct Response {
            let featured: Movie
            let nowPlaying: [Movie]
            let trending: [Movie]
            let topRated: [Movie]
            let genreFilter: GenreFilter
        }

        struct ViewModel {
            let featured: FeaturedViewModel
            let genreFilter: GenreFilterViewModel
            let nowPlaying: [MovieCardViewModel]
            let trending: [MovieCardViewModel]
            let topRated: [MovieCardViewModel]
        }
    }

    enum SelectGenre {
        struct Request {
            let index: Int
        }
    }

    enum ErrorState {
        struct ViewModel {}
    }
}

struct GenreFilter {
    let options: [String]
    let selectedIndex: Int
}

struct GenreFilterViewModel {
    let options: [String]
    let selectedIndex: Int
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
