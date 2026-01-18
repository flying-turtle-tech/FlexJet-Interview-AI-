import Foundation

// MARK: - Sign In

struct SignInRequest: Encodable {
    let username: String
    let password: String
}

struct SignInResponse: Decodable {
    let token: String
}

// MARK: - API Error Response

struct APIErrorResponse: Decodable {
    let error: String
}
