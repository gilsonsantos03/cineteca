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
            ProfileFavoriteFilmViewModel(title: $0.title, backdropURL: $0.backdropURL)
        } ?? ProfileFavoriteFilmViewModel(title: "", backdropURL: nil)

        return ProfileModels.FetchProfile.ViewModel.Content(
            header: ProfileHeaderViewModel(
                username: user.displayName.isEmpty ? user.username : user.displayName,
                memberSinceText: memberSinceText,
                avatarImageName: user.avatarImageName
            ),
            favoriteFilm: favoriteFilm,
            stats: ProfileStatsViewModel(
                filmsCount: "\(user.stats.filmsCount)",
                hoursWatched: "\(user.stats.hoursWatched)",
                reviewsCount: "\(user.stats.reviewsCount)"
            ),
            recentReviews: ProfileRecentReviewsViewModel(
                reviews: user.recentReviews.map {
                    ProfileReviewCardViewModel(
                        title: $0.title,
                        posterURL: $0.posterURL,
                        rating: $0.rating,
                        reviewText: $0.reviewText
                    )
                }
            ),
            settings: ProfileSettingsViewModel(
                rows: [
                    ProfileSettingRowViewModel(title: Strings.ProfileScene.Settings.account, setting: .account),
                    ProfileSettingRowViewModel(title: Strings.ProfileScene.Settings.notifications, setting: .notifications),
                    ProfileSettingRowViewModel(title: Strings.ProfileScene.Settings.appearance, setting: .appearance),
                    ProfileSettingRowViewModel(title: Strings.ProfileScene.Settings.language, setting: .language),
                    ProfileSettingRowViewModel(title: Strings.ProfileScene.Settings.legal, setting: .legal)
                ]
            )
        )
    }
}
