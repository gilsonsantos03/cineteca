import Foundation

protocol AppearanceRepositoryProtocol: Sendable {
    func fetchSelectedTheme() -> AppTheme
    func saveSelectedTheme(_ theme: AppTheme)
}
