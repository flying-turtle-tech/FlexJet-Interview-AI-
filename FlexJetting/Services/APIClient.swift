import Foundation

protocol APIClient {
    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let body: Encodable?
    let requiresAuth: Bool

    init(
        path: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = false
    ) {
        self.path = path
        self.method = method
        self.body = body
        self.requiresAuth = requiresAuth
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

final class URLSessionAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let tokenStorage: TokenStorage
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        session: URLSession = .shared,
        tokenStorage: TokenStorage = KeychainManager.shared
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStorage = tokenStorage

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if endpoint.requiresAuth {
            guard let token = tokenStorage.getToken() else {
                throw NetworkError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.networkFailure(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        try handleStatusCode(httpResponse.statusCode, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }

    private func handleStatusCode(_ statusCode: Int, data: Data) throws {
        switch statusCode {
        case 200...299:
            return
        case 401:
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                if errorResponse.error.lowercased().contains("expired") {
                    throw NetworkError.tokenExpired
                }
            }
            throw NetworkError.unauthorized
        default:
            let message = try? decoder.decode(APIErrorResponse.self, from: data).error
            throw NetworkError.serverError(statusCode: statusCode, message: message)
        }
    }
}
