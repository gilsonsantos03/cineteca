import Foundation

enum Strings {
    enum UI {
        static let watchTrailer = NSLocalizedString("UI.WatchTrailerButton.Title", comment: "")
    }

    enum HomeScene {
        enum GenreFilter {
            static let all = NSLocalizedString("HomeScene.GenreFilter.All.Text", comment: "")
        }

        enum Section {
            static let nowPlaying = NSLocalizedString("HomeScene.Section.NowPlaying.Title", comment: "")
            static let trending = NSLocalizedString("HomeScene.Section.Trending.Title", comment: "")
            static let topRated = NSLocalizedString("HomeScene.Section.TopRated.Title", comment: "")
            static let seeAll = NSLocalizedString("HomeScene.Section.SeeAll.Text", comment: "")
        }

        enum Error {
            static let title = NSLocalizedString("HomeScene.Error.Title", comment: "")
            static let subtitle = NSLocalizedString("HomeScene.Error.Subtitle", comment: "")
            static let retryButton = NSLocalizedString("HomeScene.Error.RetryButton.Text", comment: "")
        }

        enum Featured {
            static let watchTrailerButton = Strings.UI.watchTrailer
            static let watchlistButton = NSLocalizedString("HomeScene.Featured.WatchlistButton.Text", comment: "")
        }

        enum TrailerUnavailable {
            static let title = NSLocalizedString("HomeScene.TrailerUnavailable.Title", comment: "")
            static let message = NSLocalizedString("HomeScene.TrailerUnavailable.Message", comment: "")
            static let okButton = NSLocalizedString("HomeScene.TrailerUnavailable.OkButton.Text", comment: "")
        }

        enum Card {
            static let trendingBadge = NSLocalizedString("HomeScene.Card.TrendingBadge.Text", comment: "")
        }

        enum WeeklyDigest {
            static let title = NSLocalizedString("HomeScene.WeeklyDigest.Title", comment: "")
            static let subtitle = NSLocalizedString("HomeScene.WeeklyDigest.Subtitle", comment: "")
        }
    }

    enum TabBar {
        static let home = NSLocalizedString("TabBar.Home.Title", comment: "")
        static let search = NSLocalizedString("TabBar.Search.Title", comment: "")
        static let lists = NSLocalizedString("TabBar.Lists.Title", comment: "")
        static let stats = NSLocalizedString("TabBar.Stats.Title", comment: "")
        static let profile = NSLocalizedString("TabBar.Profile.Title", comment: "")
    }

    enum SearchScene {
        enum SearchBar {
            static let placeholder = NSLocalizedString("SearchScene.SearchBar.Placeholder", comment: "")
        }

        enum Section {
            static let suggested = NSLocalizedString("SearchScene.Section.Suggested", comment: "")
            static let results = NSLocalizedString("SearchScene.Section.Results", comment: "")
        }

        enum Filters {
            static let title = NSLocalizedString("SearchScene.Filters.Title", comment: "")
            static let genre = NSLocalizedString("SearchScene.Filters.Genre", comment: "")
            static let year = NSLocalizedString("SearchScene.Filters.Year", comment: "")
            static let minRating = NSLocalizedString("SearchScene.Filters.MinRating", comment: "")
            static let language = NSLocalizedString("SearchScene.Filters.Language", comment: "")
            static let cancel = NSLocalizedString("SearchScene.Filters.Cancel", comment: "")

            enum Language {
                static let all = NSLocalizedString("SearchScene.Filters.Language.All", comment: "")
                static let english = NSLocalizedString("SearchScene.Filters.Language.English", comment: "")
                static let portuguese = NSLocalizedString("SearchScene.Filters.Language.Portuguese", comment: "")
                static let spanish = NSLocalizedString("SearchScene.Filters.Language.Spanish", comment: "")
                static let french = NSLocalizedString("SearchScene.Filters.Language.French", comment: "")
            }
        }
    }

    enum MovieDetailsScene {
        enum Action {
            static let rate = NSLocalizedString("MovieDetailsScene.Action.Rate.Text", comment: "")
            static let favorite = NSLocalizedString("MovieDetailsScene.Action.Favorite.Text", comment: "")
            static let watchlist = NSLocalizedString("MovieDetailsScene.Action.Watchlist.Text", comment: "")
            static let readMore = NSLocalizedString("MovieDetailsScene.Action.ReadMore.Text", comment: "")
            static let watchTrailer = Strings.UI.watchTrailer
        }

        enum Section {
            static let whereToWatch = NSLocalizedString("MovieDetailsScene.Section.WhereToWatch.Title", comment: "")
            static let synopsis = NSLocalizedString("MovieDetailsScene.Section.Synopsis.Title", comment: "")
            static let cast = NSLocalizedString("MovieDetailsScene.Section.Cast.Title", comment: "")
            static let crew = NSLocalizedString("MovieDetailsScene.Section.Crew.Title", comment: "")
            static let similar = NSLocalizedString("MovieDetailsScene.Section.Similar.Title", comment: "")
        }

        enum Rating {
            static let tmdb = NSLocalizedString("MovieDetailsScene.Rating.TMDB.Text", comment: "")
        }

        enum Certification {
            static func age(_ value: String) -> String {
                String(format: NSLocalizedString("MovieDetailsScene.Certification.Age.Format", comment: ""), value)
            }

            static var accessibilityLabel: String {
                NSLocalizedString("MovieDetailsScene.Certification.Accessibility.Label", comment: "")
            }
        }

        enum Crew {
            static func job(_ key: String) -> String {
                switch key {
                case "Director":
                    NSLocalizedString("MovieDetailsScene.Crew.Job.Director", comment: "")
                case "Writer":
                    NSLocalizedString("MovieDetailsScene.Crew.Job.Writer", comment: "")
                case "Screenplay":
                    NSLocalizedString("MovieDetailsScene.Crew.Job.Screenplay", comment: "")
                default:
                    key
                }
            }
        }

        enum Error {
            static let title = NSLocalizedString("MovieDetailsScene.Error.Title", comment: "")
            static let message = NSLocalizedString("MovieDetailsScene.Error.Message", comment: "")
            static let retry = NSLocalizedString("MovieDetailsScene.Error.Retry.Text", comment: "")
        }

        enum TrailerUnavailable {
            static let title = NSLocalizedString("MovieDetailsScene.TrailerUnavailable.Title", comment: "")
            static let message = NSLocalizedString("MovieDetailsScene.TrailerUnavailable.Message", comment: "")
            static let okButton = NSLocalizedString("MovieDetailsScene.TrailerUnavailable.OkButton.Text", comment: "")
        }
    }
}
