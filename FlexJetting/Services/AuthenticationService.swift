import Foundation

protocol AuthenticationService {
    var isAuthenticated: Bool { get }
    func signIn(username: String, password: String) async throws
    func signOut() throws
}

final class DefaultAuthenticationService: AuthenticationService {
    private let apiClient: APIClient
    private let tokenStorage: TokenStorage

    init(
        apiClient: APIClient,
        tokenStorage: TokenStorage = KeychainManager.shared
    ) {
        self.apiClient = apiClient
        self.tokenStorage = tokenStorage
    }

    var isAuthenticated: Bool {
        tokenStorage.getToken() != nil
    }

    func signIn(username: String, password: String) async throws {
        let request = SignInRequest(username: username, password: password)
        let endpoint = Endpoint(
            path: "api/signIn",
            method: .post,
            body: request,
            requiresAuth: false
        )

        let response = try await apiClient.request(
            endpoint: endpoint,
            responseType: SignInResponse.self
        )

        try tokenStorage.saveToken(response.token)
    }

    func signOut() throws {
        try tokenStorage.deleteToken()
    }
}
