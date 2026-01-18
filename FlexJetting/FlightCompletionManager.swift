import Foundation
import Combine

@MainActor
final class FlightCompletionManager: ObservableObject {
    @Published private(set) var completedFlightIds: Set<String> = []

    private let completedFlightsKey = "completedFlightIds"

    init() {
        loadCompletedFlights()
    }

    func isCompleted(_ flightId: String) -> Bool {
        completedFlightIds.contains(flightId)
    }

    func toggle(_ flightId: String) {
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
