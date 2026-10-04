import Foundation

protocol ProfilePresentationLogic {
    func presentFetchProfile(response: ProfileModels.FetchProfile.Response)
    func presentLoading()
}

final class ProfilePresenter {
    weak var view: ProfileDisplayLogic?

    private let memberSinceFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}

extension ProfilePresenter: ProfilePresentationLogic {
    func presentFetchProfile(response: ProfileModels.FetchProfile.Response) {
        switch response {
        case .content(let user):
            view?.displayFetchProfile(viewModel: .content(makeContent(from: user)))
        case .error:
            view?.displayFetchProfile(viewModel: .error)
        }
    }

    func presentLoading() {
        view?.displayLoading()
    }

    private func makeContent(from user: User) -> ProfileModels.FetchProfile.ViewModel.Content {
        let memberSince = memberSinceFormatter.string(from: user.memberSince)
        let memberSinceText = String(format: Strings.ProfileScene.memberSinceFormat, memberSince)

        let favoriteFilm = user.favoriteFilm.map {
            ProfileModels.FavoriteFilmViewModel(title: $0.title, backdropURL: $0.backdropURL)
        } ?? ProfileModels.FavoriteFilmViewModel(title: "", backdropURL: nil)

        return ProfileModels.FetchProfile.ViewModel.Content(
            header: ProfileModels.HeaderViewModel(
                username: user.displayName.isEmpty ? user.username : user.displayName,
                memberSinceText: memberSinceText,
                avatarImageName: user.avatarImageName
            ),
            favoriteFilm: favoriteFilm,
            stats: ProfileModels.StatsViewModel(
                filmsCount: "\(user.stats.filmsCount)",
                hoursWatched: "\(user.stats.hoursWatched)",
                reviewsCount: "\(user.stats.reviewsCount)"
            ),
            recentReviews: ProfileModels.RecentReviewsViewModel(
                reviews: user.recentReviews.map {
                    ProfileModels.ReviewCardViewModel(
                        title: $0.title,
                        posterURL: $0.posterURL,
                        rating: $0.rating,
                        reviewText: $0.reviewText
                    )
                }
            ),
            settings: ProfileModels.SettingsViewModel(
                rows: [
                    ProfileModels.SettingRowViewModel(title: Strings.ProfileScene.Settings.account, setting: .account),
                    ProfileModels.SettingRowViewModel(title: Strings.ProfileScene.Settings.notifications, setting: .notifications),
                    ProfileModels.SettingRowViewModel(title: Strings.ProfileScene.Settings.appearance, setting: .appearance),
                    ProfileModels.SettingRowViewModel(title: Strings.ProfileScene.Settings.language, setting: .language),
                    ProfileModels.SettingRowViewModel(title: Strings.ProfileScene.Settings.legal, setting: .legal)
                ]
            )
        )
    }
}
