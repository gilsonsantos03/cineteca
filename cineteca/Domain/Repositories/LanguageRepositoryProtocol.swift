import Foundation

protocol LanguageRepositoryProtocol: Sendable {
    func fetchSelectedLanguage() -> AppLanguage
    func saveSelectedLanguage(_ language: AppLanguage)
}
