import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published private(set) var completedFlightIds: Set<String> = []

    private let authenticationService: AuthenticationService
    private let completedFlightsKey = "completedFlightIds"

    init(authenticationService: AuthenticationService) {
        self.authenticationService = authenticationService
        self.isAuthenticated = authenticationService.isAuthenticated
        loadCompletedFlights()
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

    func isFlightCompleted(_ flightId: String) -> Bool {
        completedFlightIds.contains(flightId)
    }

    func toggleFlightCompletion(_ flightId: String) {
        if completedFlightIds.contains(flightId) {
            completedFlightIds.remove(flightId)
        } else {
            completedFlightIds.insert(flightId)
        }
        saveCompletedFlights()
    }

    private func loadCompletedFlights() {
        if let data = UserDefaults.standard.data(forKey: completedFlightsKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            completedFlightIds = ids
        }
    }

    private func saveCompletedFlights() {
        if let data = try? JSONEncoder().encode(completedFlightIds) {
            UserDefaults.standard.set(data, forKey: completedFlightsKey)
        }
    }
}
