import Foundation

final class ServiceContainer {
    static let shared = ServiceContainer()

    private let baseURL = URL(string: "https://v0-simple-authentication-api.vercel.app/")!

    private lazy var apiClient: APIClient = {
        URLSessionAPIClient(baseURL: baseURL)
    }()

    private lazy var authenticationService: AuthenticationService = {
        DefaultAuthenticationService(apiClient: apiClient)
    }()

    private(set) lazy var flightService: FlightService = {
        DefaultFlightService(apiClient: apiClient)
    }()

    private(set) lazy var authState: AuthState = {
        AuthState(authenticationService: authenticationService)
    }()

    private(set) lazy var flightCompletionManager: FlightCompletionManager = {
        FlightCompletionManager()
    }()

    private init() {}
}
