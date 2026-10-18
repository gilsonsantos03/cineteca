import Foundation

enum Strings {
    enum UI {
        static var watchTrailer: String { Localization.string("UI.WatchTrailerButton.Title") }

        enum StatCards {
            static var films: String { Localization.string("UI.StatCards.Films") }
            static var hours: String { Localization.string("UI.StatCards.Hours") }
            static var reviews: String { Localization.string("UI.StatCards.Reviews") }
        }
    }

    enum HomeScene {
        enum GenreFilter {
            static var all: String { Localization.string("HomeScene.GenreFilter.All.Text") }
        }

        enum Section {
            static var nowPlaying: String { Localization.string("HomeScene.Section.NowPlaying.Title") }
            static var trending: String { Localization.string("HomeScene.Section.Trending.Title") }
            static var topRated: String { Localization.string("HomeScene.Section.TopRated.Title") }
            static var seeAll: String { Localization.string("HomeScene.Section.SeeAll.Text") }
            static var empty: String { Localization.string("HomeScene.Section.Empty.Text") }
        }

        enum Error {
            static var title: String { Localization.string("HomeScene.Error.Title") }
            static var subtitle: String { Localization.string("HomeScene.Error.Subtitle") }
            static var retryButton: String { Localization.string("HomeScene.Error.RetryButton.Text") }
        }

        enum Featured {
            static var watchTrailerButton: String { Strings.UI.watchTrailer }
            static var watchlistButton: String { Localization.string("HomeScene.Featured.WatchlistButton.Text") }
        }

        enum TrailerUnavailable {
            static var title: String { Localization.string("HomeScene.TrailerUnavailable.Title") }
            static var message: String { Localization.string("HomeScene.TrailerUnavailable.Message") }
            static var okButton: String { Localization.string("HomeScene.TrailerUnavailable.OkButton.Text") }
        }

        enum Card {
            static var trendingBadge: String { Localization.string("HomeScene.Card.TrendingBadge.Text") }
        }

        enum WeeklyDigest {
            static var title: String { Localization.string("HomeScene.WeeklyDigest.Title") }
            static var subtitle: String { Localization.string("HomeScene.WeeklyDigest.Subtitle") }
        }
    }

    enum MovieCatalogScene {
        static var loadMore: String { Localization.string("MovieCatalogScene.LoadMore") }
        static var nextPageErrorTitle: String { Localization.string("MovieCatalogScene.NextPageError.Title") }
        static var nextPageErrorMessage: String { Localization.string("MovieCatalogScene.NextPageError.Message") }
        static var okButton: String { Localization.string("MovieCatalogScene.NextPageError.OkButton") }
        static var empty: String { Localization.string("MovieCatalogScene.Empty.Text") }
    }

    enum TabBar {
        static var home: String { Localization.string("TabBar.Home.Title") }
        static var search: String { Localization.string("TabBar.Search.Title") }
        static var lists: String { Localization.string("TabBar.Lists.Title") }
        static var stats: String { Localization.string("TabBar.Stats.Title") }
        static var profile: String { Localization.string("TabBar.Profile.Title") }
    }

    enum ListsScene {
        static var title: String { Localization.string("ListsScene.Title") }
        static var removeErrorTitle: String {
            Localization.string("ListsScene.RemoveError.Title")
        }
        static var removeErrorMessage: String {
            Localization.string("ListsScene.RemoveError.Message")
        }
        static var okButton: String { Localization.string("ListsScene.Error.OkButton") }

        enum Tab {
            static var watchlist: String { Localization.string("ListsScene.Tab.Watchlist") }
            static var favorites: String { Localization.string("ListsScene.Tab.Favorites") }
            static var rated: String { Localization.string("ListsScene.Tab.Rated") }
        }

        enum Empty {
            static var watchlist: String { Localization.string("ListsScene.Empty.Watchlist") }
            static var favorites: String { Localization.string("ListsScene.Empty.Favorites") }
            static var rated: String { Localization.string("ListsScene.Empty.Rated") }
        }

        enum Card {
            static var durationFormat: String {
                Localization.string("ListsScene.Card.Duration.Format")
            }
            static var ratingScale: String {
                Localization.string("ListsScene.Card.RatingScale")
            }
            static var removeAccessibilityLabel: String {
                Localization.string("ListsScene.Card.RemoveAccessibilityLabel")
            }
        }

        enum Error {
            static var title: String { Localization.string("ListsScene.Error.Title") }
            static var subtitle: String { Localization.string("ListsScene.Error.Subtitle") }
            static var retryButton: String {
                Localization.string("ListsScene.Error.RetryButton.Text")
            }
        }
    }

    enum StatsScene {
        static var title: String { Localization.string("StatsScene.Title") }
        static var filmsWatchedFormat: String { Localization.string("StatsScene.FilmsWatched.Format") }

        enum GenreDistribution {
            static var title: String { Localization.string("StatsScene.GenreDistribution.Title") }
        }

        enum Genre {
            static var drama: String { Localization.string("StatsScene.Genre.Drama") }
            static var sciFi: String { Localization.string("StatsScene.Genre.SciFi") }
            static var thriller: String { Localization.string("StatsScene.Genre.Thriller") }
            static var comedy: String { Localization.string("StatsScene.Genre.Comedy") }
            static var other: String { Localization.string("StatsScene.Genre.Other") }
        }

        enum TopDirector {
            static var title: String { Localization.string("StatsScene.TopDirector.Title") }
        }

        enum TopActor {
            static var title: String { Localization.string("StatsScene.TopActor.Title") }
        }

        enum MonthlyActivity {
            static var title: String { Localization.string("StatsScene.MonthlyActivity.Title") }
            static var subtitle: String { Localization.string("StatsScene.MonthlyActivity.Subtitle") }
        }
    }

    enum SearchScene {
        static var selectionTitle: String { Localization.string("SearchScene.SelectionTitle") }

        enum SearchBar {
            static var placeholder: String { Localization.string("SearchScene.SearchBar.Placeholder") }
        }

        enum Section {
            static var suggested: String { Localization.string("SearchScene.Section.Suggested") }
            static var results: String { Localization.string("SearchScene.Section.Results") }
        }

        enum Filters {
            static var title: String { Localization.string("SearchScene.Filters.Title") }
            static var genre: String { Localization.string("SearchScene.Filters.Genre") }
            static var year: String { Localization.string("SearchScene.Filters.Year") }
            static var minRating: String { Localization.string("SearchScene.Filters.MinRating") }
            static var language: String { Localization.string("SearchScene.Filters.Language") }
            static var cancel: String { Localization.string("SearchScene.Filters.Cancel") }

            enum Language {
                static var all: String { Localization.string("SearchScene.Filters.Language.All") }
                static var english: String { Localization.string("SearchScene.Filters.Language.English") }
                static var portuguese: String { Localization.string("SearchScene.Filters.Language.Portuguese") }
                static var spanish: String { Localization.string("SearchScene.Filters.Language.Spanish") }
                static var french: String { Localization.string("SearchScene.Filters.Language.French") }
            }
        }
    }

    enum ProfileScene {
        static var memberSinceFormat: String { Localization.string("ProfileScene.MemberSince.Format") }
        static var signOut: String { Localization.string("ProfileScene.SignOut.Text") }

        enum FavoriteFilm {
            static var badge: String { Localization.string("ProfileScene.FavoriteFilm.Badge") }
            static var empty: String { Localization.string("ProfileScene.FavoriteFilm.Empty") }
        }

        enum RecentReviews {
            static var title: String { Localization.string("ProfileScene.RecentReviews.Title") }
            static var seeAll: String { Localization.string("ProfileScene.RecentReviews.SeeAll") }
            static var empty: String { Localization.string("ProfileScene.RecentReviews.Empty") }
            static var noComment: String { Localization.string("ProfileScene.RecentReviews.NoComment") }
        }

        enum Settings {
            static var account: String { Localization.string("ProfileScene.Settings.Account") }
            static var notifications: String { Localization.string("ProfileScene.Settings.Notifications") }
            static var appearance: String { Localization.string("ProfileScene.Settings.Appearance") }
            static var language: String { Localization.string("ProfileScene.Settings.Language") }
            static var legal: String { Localization.string("ProfileScene.Settings.Legal") }
        }
    }

    enum MyReviewsScene {
        static var title: String { Localization.string("MyReviewsScene.Title") }
        static var reviewCountFormat: String { Localization.string("MyReviewsScene.ReviewCount.Format") }
        static var updateErrorTitle: String { Localization.string("MyReviewsScene.UpdateError.Title") }
        static var updateErrorMessage: String { Localization.string("MyReviewsScene.UpdateError.Message") }
        static var okButton: String { Localization.string("MyReviewsScene.UpdateError.OkButton") }
        static var ratingScale: String { Localization.string("MyReviewsScene.RatingScale") }
        static var empty: String { Localization.string("MyReviewsScene.Empty") }
        static var noComment: String { Localization.string("MyReviewsScene.NoComment") }
    }

    enum LegalScene {
        static var title: String { Localization.string("LegalScene.Title") }

        enum Section {
            static var legal: String { Localization.string("LegalScene.Section.Legal") }
        }

        enum Row {
            static var privacyPolicy: String { Localization.string("LegalScene.Row.PrivacyPolicy") }
            static var termsOfService: String { Localization.string("LegalScene.Row.TermsOfService") }
        }
    }

    enum LegalDocumentScene {
        static var lastUpdated: String { Localization.string("LegalDocumentScene.LastUpdated") }

        enum PrivacyPolicy {
            static var title: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Title") }

            enum Section1 {
                static var title: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section1.Title") }
                static var body: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section1.Body") }
            }
            enum Section2 {
                static var title: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section2.Title") }
                static var body: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section2.Body") }
            }
            enum Section3 {
                static var title: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section3.Title") }
                static var body: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section3.Body") }
            }
            enum Section4 {
                static var title: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section4.Title") }
                static var body: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section4.Body") }
            }
            enum Section5 {
                static var title: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section5.Title") }
                static var body: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section5.Body") }
            }
            enum Section6 {
                static var title: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section6.Title") }
                static var body: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section6.Body") }
            }
            enum Section7 {
                static var title: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section7.Title") }
                static var body: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section7.Body") }
            }
            enum Section8 {
                static var title: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section8.Title") }
                static var body: String { Localization.string("LegalDocumentScene.PrivacyPolicy.Section8.Body") }
            }
        }

        enum TermsOfService {
            static var title: String { Localization.string("LegalDocumentScene.TermsOfService.Title") }

            enum Section1 {
                static var title: String { Localization.string("LegalDocumentScene.TermsOfService.Section1.Title") }
                static var body: String { Localization.string("LegalDocumentScene.TermsOfService.Section1.Body") }
            }
            enum Section2 {
                static var title: String { Localization.string("LegalDocumentScene.TermsOfService.Section2.Title") }
                static var body: String { Localization.string("LegalDocumentScene.TermsOfService.Section2.Body") }
            }
            enum Section3 {
                static var title: String { Localization.string("LegalDocumentScene.TermsOfService.Section3.Title") }
                static var body: String { Localization.string("LegalDocumentScene.TermsOfService.Section3.Body") }
            }
            enum Section4 {
                static var title: String { Localization.string("LegalDocumentScene.TermsOfService.Section4.Title") }
                static var body: String { Localization.string("LegalDocumentScene.TermsOfService.Section4.Body") }
            }
            enum Section5 {
                static var title: String { Localization.string("LegalDocumentScene.TermsOfService.Section5.Title") }
                static var body: String { Localization.string("LegalDocumentScene.TermsOfService.Section5.Body") }
            }
            enum Section6 {
                static var title: String { Localization.string("LegalDocumentScene.TermsOfService.Section6.Title") }
                static var body: String { Localization.string("LegalDocumentScene.TermsOfService.Section6.Body") }
            }
            enum Section7 {
                static var title: String { Localization.string("LegalDocumentScene.TermsOfService.Section7.Title") }
                static var body: String { Localization.string("LegalDocumentScene.TermsOfService.Section7.Body") }
            }
            enum Section8 {
                static var title: String { Localization.string("LegalDocumentScene.TermsOfService.Section8.Title") }
                static var body: String { Localization.string("LegalDocumentScene.TermsOfService.Section8.Body") }
            }
            enum Section9 {
                static var title: String { Localization.string("LegalDocumentScene.TermsOfService.Section9.Title") }
                static var body: String { Localization.string("LegalDocumentScene.TermsOfService.Section9.Body") }
            }
            enum Section10 {
                static var title: String { Localization.string("LegalDocumentScene.TermsOfService.Section10.Title") }
                static var body: String { Localization.string("LegalDocumentScene.TermsOfService.Section10.Body") }
            }
        }
    }

    enum AppearanceScene {
        static var title: String { Localization.string("AppearanceScene.Title") }

        enum Section {
            static var theme: String { Localization.string("AppearanceScene.Section.Theme") }
        }

        enum Theme {
            static var dark: String { Localization.string("AppearanceScene.Theme.Dark") }
            static var light: String { Localization.string("AppearanceScene.Theme.Light") }
            static var system: String { Localization.string("AppearanceScene.Theme.System") }
        }

        static var cancel: String { Localization.string("AppearanceScene.Cancel") }
    }

    enum LanguageScene {
        static var title: String { Localization.string("LanguageScene.Title") }

        enum Section {
            static var appLanguage: String { Localization.string("LanguageScene.Section.AppLanguage") }
        }

        static var cancel: String { Localization.string("LanguageScene.Cancel") }
    }

    enum AccountScene {
        static var title: String { Localization.string("AccountScene.Title") }

        enum Section {
            static var profile: String { Localization.string("AccountScene.Section.Profile") }
            static var security: String { Localization.string("AccountScene.Section.Security") }
            static var dangerZone: String { Localization.string("AccountScene.Section.DangerZone") }
        }

        enum Row {
            static var username: String { Localization.string("AccountScene.Row.Username") }
            static var displayName: String { Localization.string("AccountScene.Row.DisplayName") }
            static var bio: String { Localization.string("AccountScene.Row.Bio") }
            static var email: String { Localization.string("AccountScene.Row.Email") }
            static var changePassword: String { Localization.string("AccountScene.Row.ChangePassword") }
            static var deleteAccount: String { Localization.string("AccountScene.Row.DeleteAccount") }
        }
    }

    enum ChangePasswordScene {
        static var title: String { Localization.string("ChangePasswordScene.Title") }
        static var updatePassword: String { Localization.string("ChangePasswordScene.UpdatePassword") }

        enum Field {
            static var currentPassword: String { Localization.string("ChangePasswordScene.Field.CurrentPassword") }
            static var currentPasswordPlaceholder: String { Localization.string("ChangePasswordScene.Field.CurrentPasswordPlaceholder") }
            static var newPassword: String { Localization.string("ChangePasswordScene.Field.NewPassword") }
            static var newPasswordPlaceholder: String { Localization.string("ChangePasswordScene.Field.NewPasswordPlaceholder") }
            static var confirmPassword: String { Localization.string("ChangePasswordScene.Field.ConfirmPassword") }
            static var confirmPasswordPlaceholder: String { Localization.string("ChangePasswordScene.Field.ConfirmPasswordPlaceholder") }
        }

        enum Error {
            static var okButton: String { Localization.string("ChangePasswordScene.Error.OkButton") }
            static var invalidCurrentPasswordTitle: String { Localization.string("ChangePasswordScene.Error.InvalidCurrentPasswordTitle") }
            static var invalidCurrentPasswordMessage: String { Localization.string("ChangePasswordScene.Error.InvalidCurrentPasswordMessage") }
            static var passwordTooShortTitle: String { Localization.string("ChangePasswordScene.Error.PasswordTooShortTitle") }
            static var passwordTooShortMessage: String { Localization.string("ChangePasswordScene.Error.PasswordTooShortMessage") }
            static var passwordMismatchTitle: String { Localization.string("ChangePasswordScene.Error.PasswordMismatchTitle") }
            static var passwordMismatchMessage: String { Localization.string("ChangePasswordScene.Error.PasswordMismatchMessage") }
            static var genericTitle: String { Localization.string("ChangePasswordScene.Error.GenericTitle") }
            static var genericMessage: String { Localization.string("ChangePasswordScene.Error.GenericMessage") }
        }
    }

    enum EditProfileScene {
        static var title: String { Localization.string("EditProfileScene.Title") }
        static var changePhotoHint: String { Localization.string("EditProfileScene.ChangePhotoHint") }
        static var saveChanges: String { Localization.string("EditProfileScene.SaveChanges") }
        static var cancel: String { Localization.string("EditProfileScene.Cancel") }

        enum FavoriteFilm {
            static var badge: String { Localization.string("EditProfileScene.FavoriteFilm.Badge") }
            static var change: String { Localization.string("EditProfileScene.FavoriteFilm.Change") }
            static var empty: String { Localization.string("EditProfileScene.FavoriteFilm.Empty") }
        }

        enum Field {
            static var username: String { Localization.string("EditProfileScene.Field.Username") }
            static var displayName: String { Localization.string("EditProfileScene.Field.DisplayName") }
            static var bio: String { Localization.string("EditProfileScene.Field.Bio") }
        }
    }

    enum MovieDetailsScene {
        static var title: String { Localization.string("MovieDetailsScene.Title") }

        enum Action {
            static var rate: String { Localization.string("MovieDetailsScene.Action.Rate.Text") }
            static var like: String { Localization.string("MovieDetailsScene.Action.Like.Text") }
            static var watchlist: String { Localization.string("MovieDetailsScene.Action.Watchlist.Text") }
            static var readMore: String { Localization.string("MovieDetailsScene.Action.ReadMore.Text") }
            static var watchTrailer: String { Strings.UI.watchTrailer }
        }

        enum Section {
            static var whereToWatch: String { Localization.string("MovieDetailsScene.Section.WhereToWatch.Title") }
            static var synopsis: String { Localization.string("MovieDetailsScene.Section.Synopsis.Title") }
            static var cast: String { Localization.string("MovieDetailsScene.Section.Cast.Title") }
            static var crew: String { Localization.string("MovieDetailsScene.Section.Crew.Title") }
            static var similar: String { Localization.string("MovieDetailsScene.Section.Similar.Title") }
        }

        enum Rating {
            static var tmdb: String { Localization.string("MovieDetailsScene.Rating.TMDB.Text") }
        }

        enum Favorite {
            static var disabledHint: String {
                Localization.string("MovieDetailsScene.Favorite.DisabledHint")
            }
        }

        enum RatingPicker {
            static var title: String {
                Localization.string("MovieDetailsScene.RatingPicker.Title")
            }

            static var cancel: String {
                Localization.string("MovieDetailsScene.RatingPicker.Cancel")
            }
        }

        enum Review {
            static var title: String {
                Localization.string("MovieDetailsScene.Review.Title")
            }

            static var yourRating: String {
                Localization.string("MovieDetailsScene.Review.YourRating")
            }

            static var outOfTen: String {
                Localization.string("MovieDetailsScene.Review.OutOfTen")
            }

            static var placeholder: String {
                Localization.string("MovieDetailsScene.Review.Placeholder")
            }

            static var submit: String {
                Localization.string("MovieDetailsScene.Review.Submit")
            }

            static var skip: String {
                Localization.string("MovieDetailsScene.Review.Skip")
            }

            static var ratingFormat: String {
                Localization.string("MovieDetailsScene.Review.RatingFormat")
            }

            static var ratingRequired: String {
                Localization.string("MovieDetailsScene.Review.RatingRequired")
            }

            static var notForMe: String {
                Localization.string("MovieDetailsScene.Review.NotForMe")
            }

            static var terrible: String {
                Localization.string("MovieDetailsScene.Review.Terrible")
            }

            static var bad: String {
                Localization.string("MovieDetailsScene.Review.Bad")
            }

            static var okay: String {
                Localization.string("MovieDetailsScene.Review.Okay")
            }

            static var good: String {
                Localization.string("MovieDetailsScene.Review.Good")
            }

            static var great: String {
                Localization.string("MovieDetailsScene.Review.Great")
            }

            static var masterpiece: String {
                Localization.string("MovieDetailsScene.Review.Masterpiece")
            }
        }

        enum ActivityError {
            static var title: String {
                Localization.string("MovieDetailsScene.ActivityError.Title")
            }

            static var message: String {
                Localization.string("MovieDetailsScene.ActivityError.Message")
            }

            static var okButton: String {
                Localization.string("MovieDetailsScene.ActivityError.OkButton")
            }
        }

        enum Certification {
            static func age(_ value: String) -> String {
                String(format: Localization.string("MovieDetailsScene.Certification.Age.Format", comment: ""), value)
            }

            static var accessibilityLabel: String {
                Localization.string("MovieDetailsScene.Certification.Accessibility.Label", comment: "")
            }
        }

        enum Crew {
            static func job(_ key: String) -> String {
                switch key {
                case "Director":
                    Localization.string("MovieDetailsScene.Crew.Job.Director", comment: "")
                case "Writer":
                    Localization.string("MovieDetailsScene.Crew.Job.Writer", comment: "")
                case "Screenplay":
                    Localization.string("MovieDetailsScene.Crew.Job.Screenplay", comment: "")
                default:
                    key
                }
            }
        }

        enum Error {
            static var title: String { Localization.string("MovieDetailsScene.Error.Title") }
            static var message: String { Localization.string("MovieDetailsScene.Error.Message") }
            static var retry: String { Localization.string("MovieDetailsScene.Error.Retry.Text") }
        }

        enum TrailerUnavailable {
            static var title: String { Localization.string("MovieDetailsScene.TrailerUnavailable.Title") }
            static var message: String { Localization.string("MovieDetailsScene.TrailerUnavailable.Message") }
            static var okButton: String { Localization.string("MovieDetailsScene.TrailerUnavailable.OkButton.Text") }
        }
    }

}
