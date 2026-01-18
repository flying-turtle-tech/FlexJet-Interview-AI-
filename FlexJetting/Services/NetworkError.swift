import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case decodingFailed(String)
    case unauthorized
    case tokenExpired
    case serverError(statusCode: Int, message: String?)
    case networkFailure(String)
    case unknown

    var isAuthenticationError: Bool {
        switch self {
        case .unauthorized, .tokenExpired:
            return true
        default:
            return false
        }
    }

    var userFacingMessage: String {
        switch self {
        case .invalidURL:
            return "Invalid request URL."
        case .noData:
            return "No data received from server."
        case .decodingFailed:
            return "Failed to process server response."
        case .unauthorized:
            return "Invalid credentials. Please try again."
        case .tokenExpired:
            return "Your session has expired. Please sign in again."
        case .serverError(let statusCode, let message):
            if let message = message {
                return message
            }
            return "Server error (code: \(statusCode)). Please try again later."
        case .networkFailure(let message):
            return "Network error: \(message)"
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}
