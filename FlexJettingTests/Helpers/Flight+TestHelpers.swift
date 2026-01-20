import Foundation
@testable import FlexJetting

extension Flight {
    nonisolated static func testFlight(
        id: String = "test-id",
        tripNumber: String = "1234567",
        flightNumber: String? = "UA123",
        tailNumber: String = "N12345",
        origin: String = "Los Angeles (LAX)",
        originIata: String = "LAX",
        destination: String = "New York (JFK)",
        destinationIata: String = "JFK",
        departure: Date = Date().addingTimeInterval(3600),
        arrival: Date = Date().addingTimeInterval(7200),
        price: Int = 15000
    ) -> Flight {
        Flight(
            id: id,
            tripNumber: tripNumber,
            flightNumber: flightNumber,
            tailNumber: tailNumber,
            origin: origin,
            originIata: originIata,
            destination: destination,
            destinationIata: destinationIata,
            departure: departure,
            arrival: arrival,
            price: price
        )
    }
}
