import XCTest
@testable import FlexJetting

final class FlightTests: XCTestCase {

    // MARK: - Price Formatting

    func testPriceInDollarsConvertsFromCents() {
        let flight = Flight.testFlight(price: 15000)

        XCTAssertEqual(flight.priceInDollars, 150)
    }

    func testPriceInDollarsHandlesZero() {
        let flight = Flight.testFlight(price: 0)

        XCTAssertEqual(flight.priceInDollars, 0)
    }

    func testPriceInDollarsTruncatesPartialDollars() {
        let flight = Flight.testFlight(price: 15099)

        XCTAssertEqual(flight.priceInDollars, 150)
    }

    func testFormattedPriceIncludesDollarSign() {
        let flight = Flight.testFlight(price: 15000)

        XCTAssertEqual(flight.formattedPrice, "$150")
    }

    func testFormattedPriceHandlesZero() {
        let flight = Flight.testFlight(price: 0)

        XCTAssertEqual(flight.formattedPrice, "$0")
    }

    // MARK: - City Extraction

    func testOriginCityExtractsNameBeforeParentheses() {
        let flight = Flight.testFlight(origin: "Los Angeles (LAX)")

        XCTAssertEqual(flight.originCity, "Los Angeles")
    }

    func testOriginCityReturnsFullStringWhenNoParentheses() {
        let flight = Flight.testFlight(origin: "Los Angeles")

        XCTAssertEqual(flight.originCity, "Los Angeles")
    }

    func testOriginCityTrimsWhitespace() {
        let flight = Flight.testFlight(origin: "  Los Angeles  (LAX)")

        XCTAssertEqual(flight.originCity, "Los Angeles")
    }

    func testDestinationCityExtractsNameBeforeParentheses() {
        let flight = Flight.testFlight(destination: "New York (JFK)")

        XCTAssertEqual(flight.destinationCity, "New York")
    }

    func testDestinationCityReturnsFullStringWhenNoParentheses() {
        let flight = Flight.testFlight(destination: "New York")

        XCTAssertEqual(flight.destinationCity, "New York")
    }

    func testDestinationCityTrimsWhitespace() {
        let flight = Flight.testFlight(destination: "New York   (JFK)")

        XCTAssertEqual(flight.destinationCity, "New York")
    }

    // MARK: - isToday

    func testIsTodayReturnsTrueForFutureFlightToday() {
        let futureToday = Date().addingTimeInterval(3600)
        let flight = Flight.testFlight(departure: futureToday)

        XCTAssertTrue(flight.isToday)
    }

    func testIsTodayReturnsFalseForPastFlightToday() {
        let pastToday = Date().addingTimeInterval(-3600)
        let flight = Flight.testFlight(departure: pastToday)

        XCTAssertFalse(flight.isToday)
    }

    func testIsTodayReturnsFalseForTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let flight = Flight.testFlight(departure: tomorrow)

        XCTAssertFalse(flight.isToday)
    }

    func testIsTodayReturnsFalseForYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let flight = Flight.testFlight(departure: yesterday)

        XCTAssertFalse(flight.isToday)
    }

    // MARK: - Equatable

    func testFlightsWithSameDataAreEqual() {
        let fixedDeparture = Date.now.addingTimeInterval(100)
        let fixedArrival = Date.now.addingTimeInterval(1000)

        let flight1 = Flight.testFlight(id: "same-id", departure: fixedDeparture, arrival: fixedArrival)
        let flight2 = Flight.testFlight(id: "same-id", departure: fixedDeparture, arrival: fixedArrival)

        XCTAssertEqual(flight1, flight2)
    }

    func testFlightsWithDifferentIdsAreNotEqual() {
        let flight1 = Flight.testFlight(id: "id-1")
        let flight2 = Flight.testFlight(id: "id-2")

        XCTAssertNotEqual(flight1, flight2)
    }

    // MARK: - Placeholder

    func testPlaceholderHasExpectedValues() {
        let placeholder = Flight.placeholder

        XCTAssertEqual(placeholder.id, "placeholder")
        XCTAssertEqual(placeholder.tripNumber, "0000")
        XCTAssertEqual(placeholder.price, 0)
    }
}
