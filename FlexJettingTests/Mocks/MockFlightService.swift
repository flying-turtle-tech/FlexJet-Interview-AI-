import Foundation
@testable import FlexJetting

final class MockFlightService: FlightService {
    var flightsToReturn: [Flight] = []
    var errorToThrow: Error?
    var fetchFlightsCalled = false
    var delay: Duration?

    func fetchFlights() async throws -> [Flight] {
        fetchFlightsCalled = true
        if let delay {
            try await Task.sleep(for: delay)
        }
        if let error = errorToThrow {
            throw error
        }
        return flightsToReturn
    }
}
