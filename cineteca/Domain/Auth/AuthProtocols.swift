import Foundation

protocol AuthRepositoryProtocol: AnyObject, Sendable {
    var state: AuthState { get }
    func signIn(with credential: AuthProviderCredential) async throws -> AuthenticatedUser
    func signIn(email: String, password: String) async throws -> AuthenticatedUser
    func createAccount(email: String, password: String, username: String?) async throws -> AuthenticatedUser
    func createProfileIfNeeded(username: String?) async throws
    func sendPasswordReset(to email: String) async throws
    func signOut() throws
    func deleteAccount() async throws
}

protocol AuthenticationProviderProtocol: AnyObject {
    var identifier: String { get }
    func authenticate() async throws -> AuthProviderCredential
}

@MainActor
protocol AuthenticationGateProtocol: AnyObject {
    var isAuthenticated: Bool { get }
    func performAuthenticated(_ action: @escaping @MainActor () -> Void)
    func requestAuthentication()
}
