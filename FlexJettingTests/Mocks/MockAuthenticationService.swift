import Foundation
@testable import FlexJetting

final class MockAuthenticationService: AuthenticationService {
    var isAuthenticatedValue = false
    var signInError: Error?
    var signOutError: Error?
    var signInCalled = false
    var signOutCalled = false
    var lastUsername: String?
    var lastPassword: String?

    var isAuthenticated: Bool {
        isAuthenticatedValue
    }

    func signIn(username: String, password: String) async throws {
        signInCalled = true
        lastUsername = username
        lastPassword = password
        if let error = signInError {
            throw error
        }
        isAuthenticatedValue = true
    }

    func signOut() throws {
        signOutCalled = true
        if let error = signOutError {
            throw error
        }
        isAuthenticatedValue = false
    }
}
