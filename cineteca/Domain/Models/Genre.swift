import Foundation

struct Genre: Sendable, Hashable {
    let id: Int
    let name: String
}

extension Array where Element == Genre {
    var lookupById: [Int: Genre] {
        Dictionary(uniqueKeysWithValues: map { ($0.id, $0) })
    }
}
