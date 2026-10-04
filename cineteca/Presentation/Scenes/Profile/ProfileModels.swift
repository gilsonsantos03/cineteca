import Foundation

enum ProfileModels {
    enum FetchProfile {
        struct Request {}

        enum Response {
            case content(User)
            case error
        }

        enum ViewModel {
            case content(Content)
            case error

            struct Content {
                let header: HeaderViewModel
                let favoriteFilm: FavoriteFilmViewModel
                let stats: StatsViewModel
                let recentReviews: RecentReviewsViewModel
                let settings: SettingsViewModel
            }
        }
    }

    struct HeaderViewModel {
        let username: String
        let memberSinceText: String
        let avatarImageName: String?
    }

    struct FavoriteFilmViewModel {
        let title: String
        let backdropURL: URL?
    }

    struct StatsViewModel {
        let filmsCount: String
        let hoursWatched: String
        let reviewsCount: String
    }

    struct ReviewCardViewModel {
        let title: String
        let posterURL: URL?
        let rating: Double
        let reviewText: String
    }

    struct RecentReviewsViewModel {
        let reviews: [ReviewCardViewModel]
    }

    struct SettingsViewModel {
        let rows: [SettingRowViewModel]
    }

    struct SettingRowViewModel {
        let title: String
        let setting: Setting
    }

    enum Setting {
        case account
        case notifications
        case appearance
        case language
        case legal
    }
}
