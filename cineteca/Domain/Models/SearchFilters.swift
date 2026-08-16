import Foundation

struct SearchFilters: Equatable, Sendable {
    var selectedGenreIds: Set<Int> = []
    var yearFrom: Int
    var yearTo: Int
    var minRating: Int
    var languageCode: String?

    init(
        selectedGenreIds: Set<Int> = [],
        yearFrom: Int = 1990,
        yearTo: Int = Calendar.current.component(.year, from: Date()),
        minRating: Int = 0,
        languageCode: String? = nil
    ) {
        self.selectedGenreIds = selectedGenreIds
        self.yearFrom = yearFrom
        self.yearTo = yearTo
        self.minRating = minRating
        self.languageCode = languageCode
    }

    var hasActiveFilters: Bool {
        let currentYear = Calendar.current.component(.year, from: Date())
        return !selectedGenreIds.isEmpty
            || yearFrom != 1990
            || yearTo != currentYear
            || minRating > 0
            || languageCode != nil
    }
}
