import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authState: AuthState

    var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    init(authState: AuthState) {
        self.authState = authState
    }

    func signIn() async {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await authState.signIn(
                username: username.trimmingCharacters(in: .whitespaces),
                password: password
            )
        } catch let error as NetworkError {
            errorMessage = error.userFacingMessage
        } catch {
            errorMessage = "An unexpected error occurred. Please try again."
        }

        isLoading = false
    }
}
