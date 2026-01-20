import XCTest
@testable import FlexJetting

final class FlightCardViewModelTests: XCTestCase {

    // MARK: - Title Tests

    func testTitleFormatsOriginAndDestinationCities() {
        let flight = Flight.testFlight(
            origin: "Los Angeles (LAX)",
            destination: "New York (JFK)"
        )

        let sut = FlightCardViewModel(flight: flight)

        XCTAssertEqual(sut.title, "Los Angeles to New York")
    }

    func testTitleHandlesLocationsWithoutParentheses() {
        let flight = Flight.testFlight(
            origin: "Los Angeles",
            destination: "New York"
        )

        let sut = FlightCardViewModel(flight: flight)

        XCTAssertEqual(sut.title, "Los Angeles to New York")
    }

    func testTitleTrimsWhitespaceFromCityNames() {
        let flight = Flight.testFlight(
            origin: "  Los Angeles  (LAX)",
            destination: "New York   (JFK)"
        )

        let sut = FlightCardViewModel(flight: flight)

        XCTAssertEqual(sut.title, "Los Angeles to New York")
    }

    // MARK: - Subtitle Tests

    func testSubtitleFormatsDepartureAndArrivalTimes() {
        var calendar = Calendar.current
        calendar.timeZone = .current

        var departureComponents = DateComponents()
        departureComponents.year = 2026
        departureComponents.month = 1
        departureComponents.day = 15
        departureComponents.hour = 9
        departureComponents.minute = 30
        let departure = calendar.date(from: departureComponents)!

        var arrivalComponents = DateComponents()
        arrivalComponents.year = 2026
        arrivalComponents.month = 1
        arrivalComponents.day = 15
        arrivalComponents.hour = 14
        arrivalComponents.minute = 45
        let arrival = calendar.date(from: arrivalComponents)!

        let flight = Flight.testFlight(departure: departure, arrival: arrival)

        let sut = FlightCardViewModel(flight: flight)

        XCTAssertTrue(sut.subtitle.contains("9:30 AM"))
        XCTAssertTrue(sut.subtitle.contains("2:45 PM"))
        XCTAssertTrue(sut.subtitle.contains(" - "))
    }

    // MARK: - isToday Tests

    func testIsTodayReturnsTrueForTodaysFutureFlight() {
        let futureToday = Date().addingTimeInterval(3600)
        let flight = Flight.testFlight(departure: futureToday)

        let sut = FlightCardViewModel(flight: flight)

        XCTAssertTrue(sut.isToday)
    }

    func testIsTodayReturnsFalseForTomorrowsFlight() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let flight = Flight.testFlight(departure: tomorrow)

        let sut = FlightCardViewModel(flight: flight)

        XCTAssertFalse(sut.isToday)
    }

    func testIsTodayReturnsFalseForPastFlightToday() {
        let pastToday = Date().addingTimeInterval(-3600)
        let flight = Flight.testFlight(departure: pastToday)

        let sut = FlightCardViewModel(flight: flight)

        XCTAssertFalse(sut.isToday)
    }

    func testIsTodayReturnsFalseForYesterdaysFlight() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let flight = Flight.testFlight(departure: yesterday)

        let sut = FlightCardViewModel(flight: flight)

        XCTAssertFalse(sut.isToday)
    }
}
