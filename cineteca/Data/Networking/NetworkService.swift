import Foundation

protocol NetworkServiceProtocol: Sendable {
    func request<T: Decodable>(_ builder: any URLRequestBuilder) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    private let configuration: NetworkConfiguration
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        configuration: NetworkConfiguration,
        session: URLSession = .shared,
        decoder: JSONDecoder = .snakeCase,
        encoder: JSONEncoder = .snakeCase
    ) {
        self.configuration = configuration
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func request<T: Decodable>(_ builder: any URLRequestBuilder) async throws -> T {
        let urlRequest = try makeURLRequest(from: builder)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw NetworkError.from(statusCode: nil, data: nil, underlyingError: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.from(
                statusCode: httpResponse.statusCode,
                data: data,
                underlyingError: nil
            )
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    private func makeURLRequest(from builder: any URLRequestBuilder) throws -> URLRequest {
        let url = configuration.baseURL.appendingPathComponent(builder.path)

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidResponse
        }

        if !builder.queryItems.isEmpty {
            components.queryItems = (components.queryItems ?? []) + builder.queryItems
        }

        guard let finalURL = components.url else {
            throw NetworkError.invalidResponse
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = builder.method.rawValue

        configuration.defaultHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        builder.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = builder.body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.from(statusCode: nil, data: nil, underlyingError: error)
            }
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        return request
    }
}
