import Foundation
import Combine

@MainActor
final class AuthState: ObservableObject {
    @Published private(set) var isAuthenticated: Bool = false

    private let authenticationService: AuthenticationService

    init(authenticationService: AuthenticationService) {
        self.authenticationService = authenticationService
        self.isAuthenticated = authenticationService.isAuthenticated
    }

    func signIn(username: String, password: String) async throws {
        try await authenticationService.signIn(username: username, password: password)
        isAuthenticated = true
    }

    func signOut() {
        do {
            try authenticationService.signOut()
            isAuthenticated = false
        } catch {
            // Handle error silently - user will remain logged in
        }
    }
}
