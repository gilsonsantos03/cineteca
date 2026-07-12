import Foundation

enum Strings {
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
            static let watchTrailerButton = NSLocalizedString("HomeScene.Featured.WatchTrailerButton.Text", comment: "")
            static let watchlistButton = NSLocalizedString("HomeScene.Featured.WatchlistButton.Text", comment: "")
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
}
