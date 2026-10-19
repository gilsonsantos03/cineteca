import Foundation

enum EditProfileModels {
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
                let username: String
                let displayName: String
                let bio: String
                let favoriteFilm: FavoriteFilmViewModel?
                let avatarImageName: String?
            }
        }
    }

    enum SaveProfile {
        struct Request {
            let username: String
            let displayName: String
            let bio: String
            let favoriteFilm: FavoriteFilmViewModel?
        }

        enum Response {
            case success
            case error(UserProfileError?)
        }

        enum ViewModel {
            case success
            case error(UserProfileError?)
        }
    }

    struct FavoriteFilmViewModel: Equatable {
        let movieId: Int
        let title: String
        let backdropURL: URL?
    }
}
