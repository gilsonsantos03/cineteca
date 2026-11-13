import Foundation

final class UserScopedCache<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var entry: (userID: String, value: Value)?

    func value(for userID: String) -> Value? {
        lock.withLock {
            entry?.userID == userID ? entry?.value : nil
        }
    }

    func store(_ value: Value, for userID: String) {
        lock.withLock {
            entry = (userID, value)
        }
    }

    func clear() {
        lock.withLock {
            entry = nil
        }
    }
}
