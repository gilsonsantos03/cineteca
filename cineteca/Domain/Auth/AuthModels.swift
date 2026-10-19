import Foundation

enum AuthState: Equatable, Sendable {
    case guest
    case authenticated(userID: String)
}

struct AuthProviderCredential: Sendable {
    let providerID: String
    let idToken: String
    let rawNonce: String?
}

struct AuthenticatedUser: Equatable, Sendable {
    let id: String
    let email: String?
    let displayName: String?
}

enum AuthenticationError: LocalizedError, Equatable {
    case cancelled
    case invalidCredential
    case invalidCredentials
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case passwordMismatch
    case networkError
    case tooManyRequests
    case userDisabled
    case operationNotAllowed
    case notConfigured
    case unavailable
    case userNotAuthenticated
    case deletionRequiresRecentLogin
    case underlying(message: String)

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "A autenticação foi cancelada."
        case .invalidCredential:
            return "Não foi possível validar a credencial."
        case .invalidCredentials:
            return "E-mail ou senha incorretos."
        case .invalidEmail:
            return "Informe um e-mail válido."
        case .weakPassword:
            return "A senha deve ter pelo menos 6 caracteres."
        case .emailAlreadyInUse:
            return "Esse e-mail já possui uma conta."
        case .passwordMismatch:
            return "As senhas não coincidem."
        case .networkError:
            return "Não foi possível conectar ao serviço. Verifique sua internet e tente novamente."
        case .tooManyRequests:
            return "Muitas tentativas. Aguarde um pouco e tente novamente."
        case .userDisabled:
            return "Esta conta está desativada."
        case .operationNotAllowed:
            return "Este método de autenticação não está disponível no momento."
        case .notConfigured:
            return "A autenticação ainda não está configurada."
        case .unavailable:
            return "A autenticação está temporariamente indisponível."
        case .userNotAuthenticated:
            return "Faça login para continuar."
        case .deletionRequiresRecentLogin:
            return "Entre novamente para excluir sua conta."
        case let .underlying(message):
            return message
        }
    }
}

protocol AuthRepositoryProtocol: AnyObject, Sendable {
    var state: AuthState { get }
    func signIn(with credential: AuthProviderCredential) async throws -> AuthenticatedUser
    func signIn(email: String, password: String) async throws -> AuthenticatedUser
    func createAccount(email: String, password: String) async throws -> AuthenticatedUser
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
}
