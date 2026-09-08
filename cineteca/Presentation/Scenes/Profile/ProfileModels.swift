import Foundation

struct ProfileModels {
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
                let header: ProfileHeaderViewModel
                let favoriteFilm: ProfileFavoriteFilmViewModel
                let stats: ProfileStatsViewModel
                let recentReviews: ProfileRecentReviewsViewModel
                let settings: ProfileSettingsViewModel
            }
        }
    }
}

struct ProfileHeaderViewModel {
    let username: String
    let memberSinceText: String
    let avatarImageName: String?
}

struct ProfileFavoriteFilmViewModel {
    let title: String
    let backdropURL: URL?
}

struct ProfileStatsViewModel {
    let filmsCount: String
    let hoursWatched: String
    let reviewsCount: String
}

struct ProfileReviewCardViewModel {
    let title: String
    let posterURL: URL?
    let rating: Double
    let reviewText: String
}

struct ProfileRecentReviewsViewModel {
    let reviews: [ProfileReviewCardViewModel]
}

struct ProfileSettingsViewModel {
    let rows: [ProfileSettingRowViewModel]
}

struct ProfileSettingRowViewModel {
    let title: String
    let setting: ProfileSetting
}

enum ProfileSetting {
    case account
    case notifications
    case appearance
    case language
    case legal
}
