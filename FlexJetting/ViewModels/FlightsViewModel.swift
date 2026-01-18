import Foundation
import Combine

enum FlightFilter: String, CaseIterable {
    case upcoming = "Upcoming"
    case past = "Past"
}

@MainActor
final class FlightsViewModel: ObservableObject {
    @Published private(set) var flights: [Flight] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var selectedFilter: FlightFilter = .upcoming

    private let flightService: FlightService

    var filteredFlights: [Flight] {
        let now = Date()

        switch selectedFilter {
        case .upcoming:
            return flights.filter { $0.departure >= now }
                .sorted { $0.departure < $1.departure }
        case .past:
            return flights.filter { $0.departure < now }
                .sorted { $0.departure > $1.departure }
        }
    }

    init(flightService: FlightService) {
        self.flightService = flightService
    }

    func fetchFlights() async {
        isLoading = true
        errorMessage = nil

        do {
            flights = try await flightService.fetchFlights()
        } catch let error as NetworkError {
            errorMessage = error.userFacingMessage
        } catch {
            errorMessage = "Failed to load flights. Please try again."
        }

        isLoading = false
    }

    func isFlightToday(_ flight: Flight) -> Bool {
        Calendar.current.isDateInToday(flight.departure) && flight.departure >= Date()
    }
}
