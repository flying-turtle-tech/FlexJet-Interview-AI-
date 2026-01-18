import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authenticationService: AuthenticationService
    private let onLoginSuccess: () -> Void

    var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    init(
        authenticationService: AuthenticationService,
        onLoginSuccess: @escaping () -> Void
    ) {
        self.authenticationService = authenticationService
        self.onLoginSuccess = onLoginSuccess
    }

    func signIn() async {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await authenticationService.signIn(
                username: username.trimmingCharacters(in: .whitespaces),
                password: password
            )
            onLoginSuccess()
        } catch let error as NetworkError {
            errorMessage = error.userFacingMessage
        } catch {
            errorMessage = "An unexpected error occurred. Please try again."
        }

        isLoading = false
    }
}
