import Foundation
@testable import FlexJetting

final class MockFlightService: FlightService {
    var flightsToReturn: [Flight] = []
    var errorToThrow: Error?
    var fetchFlightsCalled = false

    func fetchFlights() async throws -> [Flight] {
        fetchFlightsCalled = true
        if let error = errorToThrow {
            throw error
        }
        return flightsToReturn
    }
}
