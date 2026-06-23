import Alamofire
import Foundation

protocol NetworkServiceProtocol: Sendable {
    func request<T: Decodable>(_ request: any URLRequestBuilder) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {

    private let session: Session

    init(session: Session = .default) {
        self.session = session
    }

    func request<T: Decodable>(_ request: any URLRequestBuilder) async throws -> T {
        let response = await session.request(request)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self)
            .response

        if let value = response.value {
            return value
        }

        throw NetworkError.from(
            statusCode: response.response?.statusCode,
            data: response.data,
            underlyingError: response.error
        )
    }
}
