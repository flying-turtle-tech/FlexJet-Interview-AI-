import Foundation
@testable import FlexJetting

final class MockAPIClient: APIClient {
    var responseToReturn: Any?
    var errorToThrow: Error?
    var requestCalled = false
    var lastEndpoint: Endpoint?

    func request<T: Decodable>(endpoint: Endpoint, responseType: T.Type) async throws -> T {
        requestCalled = true
        lastEndpoint = endpoint

        if let error = errorToThrow {
            throw error
        }

        guard let response = responseToReturn as? T else {
            throw NetworkError.decodingFailed("Mock response type mismatch")
        }

        return response
    }
}
