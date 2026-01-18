import Foundation
import Combine

@MainActor
final class AuthState: ObservableObject {
    @Published var isAuthenticated: Bool = false

    private let authenticationService: AuthenticationService

    init(authenticationService: AuthenticationService) {
        self.authenticationService = authenticationService
        self.isAuthenticated = authenticationService.isAuthenticated
    }

    func checkAuthenticationStatus() {
        isAuthenticated = authenticationService.isAuthenticated
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
