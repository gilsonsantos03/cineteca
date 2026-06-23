import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int)
    case decodingFailed(Error)
    case apiError(message: String?)
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Resposta inválida do servidor."
        case .unauthorized:
            return "Não autorizado."
        case .forbidden:
            return "Acesso negado."
        case .notFound:
            return "Recurso não encontrado."
        case .serverError(let statusCode):
            return "Erro no servidor (código \(statusCode))."
        case .decodingFailed:
            return "Falha ao processar a resposta."
        case .apiError(let message):
            return message ?? "Erro desconhecido da API."
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}

private struct APIErrorResponse: Decodable {
    let message: String?
    let statusMessage: String?

    enum CodingKeys: String, CodingKey {
        case message
        case statusMessage = "status_message"
    }

    var resolvedMessage: String? {
        message ?? statusMessage
    }
}

extension NetworkError {
    static func from(
        statusCode: Int?,
        data: Data?,
        underlyingError: Error?
    ) -> NetworkError {
        if let statusCode {
            switch statusCode {
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 500...599:
                return .serverError(statusCode: statusCode)
            default:
                break
            }
        }

        if let data,
           let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
           let message = apiError.resolvedMessage {
            return .apiError(message: message)
        }

        if let underlyingError {
            if underlyingError is DecodingError {
                return .decodingFailed(underlyingError)
            }
            return .underlying(underlyingError)
        }

        return .invalidResponse
    }
}
