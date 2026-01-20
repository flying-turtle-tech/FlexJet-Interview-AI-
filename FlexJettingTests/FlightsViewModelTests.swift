import XCTest
@testable import FlexJetting

@MainActor
final class FlightsViewModelTests: XCTestCase {
    private var sut: FlightsViewModel!
    private var mockFlightService: MockFlightService!

    override func setUp() {
        super.setUp()
        mockFlightService = MockFlightService()
        sut = FlightsViewModel(flightService: mockFlightService)
    }

    override func tearDown() {
        sut = nil
        mockFlightService = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialStateIsCorrect() {
        XCTAssertTrue(sut.flights.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.selectedFilter, .upcoming)
    }

    // MARK: - Fetch Flights

    func testFetchFlightsSuccessUpdatesFlights() async {
        let expectedFlights = [Flight.testFlight()]
        mockFlightService.flightsToReturn = expectedFlights

        await sut.fetchFlights()

        XCTAssertTrue(mockFlightService.fetchFlightsCalled)
        XCTAssertEqual(sut.flights.count, 1)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    // TODO: - this doesnt really do anything
    func testFetchFlightsSetsLoadingState() async {
        mockFlightService.flightsToReturn = []

        await sut.fetchFlights()

        XCTAssertFalse(sut.isLoading)
    }

    func testFetchFlightsNetworkErrorSetsUserFacingMessage() async {
        mockFlightService.errorToThrow = NetworkError.unauthorized

        await sut.fetchFlights()

        XCTAssertEqual(sut.errorMessage, NetworkError.unauthorized.userFacingMessage)
        XCTAssertTrue(sut.flights.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }

    func testFetchFlightsUnknownErrorSetsGenericMessage() async {
        mockFlightService.errorToThrow = NSError(domain: "test", code: 1)

        await sut.fetchFlights()

        XCTAssertEqual(sut.errorMessage, "Failed to load flights. Please try again.")
        XCTAssertTrue(sut.flights.isEmpty)
    }

    func testFetchFlightsClearsExistingError() async {
        mockFlightService.errorToThrow = NetworkError.unauthorized
        await sut.fetchFlights()
        XCTAssertNotNil(sut.errorMessage)

        mockFlightService.errorToThrow = nil
        mockFlightService.flightsToReturn = [Flight.testFlight()]
        await sut.fetchFlights()

        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Filtered Flights (Upcoming)

    func testFilteredFlightsUpcomingReturnsOnlyFutureFlights() async {
        let pastFlight = Flight.testFlight(id: "past", departure: Date().addingTimeInterval(-3600))
        let futureFlight = Flight.testFlight(id: "future", departure: Date().addingTimeInterval(3600))
        mockFlightService.flightsToReturn = [pastFlight, futureFlight]
        await sut.fetchFlights()

        sut.selectedFilter = .upcoming
        let filtered = sut.filteredFlights

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.id, "future")
    }

    func testFilteredFlightsUpcomingSortsAscendingByDeparture() async {
        let laterFlight = Flight.testFlight(id: "later", departure: Date().addingTimeInterval(7200))
        let soonerFlight = Flight.testFlight(id: "sooner", departure: Date().addingTimeInterval(3600))
        mockFlightService.flightsToReturn = [laterFlight, soonerFlight]
        await sut.fetchFlights()

        sut.selectedFilter = .upcoming
        let filtered = sut.filteredFlights

        XCTAssertEqual(filtered[0].id, "sooner")
        XCTAssertEqual(filtered[1].id, "later")
    }

    // MARK: - Filtered Flights (Past)

    func testFilteredFlightsPastReturnsOnlyPastFlights() async {
        let pastFlight = Flight.testFlight(id: "past", departure: Date().addingTimeInterval(-3600))
        let futureFlight = Flight.testFlight(id: "future", departure: Date().addingTimeInterval(3600))
        mockFlightService.flightsToReturn = [pastFlight, futureFlight]
        await sut.fetchFlights()

        sut.selectedFilter = .past
        let filtered = sut.filteredFlights

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.id, "past")
    }

    func testFilteredFlightsPastSortsDescendingByDeparture() async {
        let olderFlight = Flight.testFlight(id: "older", departure: Date().addingTimeInterval(-7200))
        let newerFlight = Flight.testFlight(id: "newer", departure: Date().addingTimeInterval(-3600))
        mockFlightService.flightsToReturn = [olderFlight, newerFlight]
        await sut.fetchFlights()

        sut.selectedFilter = .past
        let filtered = sut.filteredFlights

        XCTAssertEqual(filtered[0].id, "newer")
        XCTAssertEqual(filtered[1].id, "older")
    }

    // MARK: - Filter Switching

    func testSwitchingFiltersUpdatesFilteredFlights() async {
        let pastFlight = Flight.testFlight(id: "past", departure: Date().addingTimeInterval(-3600))
        let futureFlight = Flight.testFlight(id: "future", departure: Date().addingTimeInterval(3600))
        mockFlightService.flightsToReturn = [pastFlight, futureFlight]
        await sut.fetchFlights()

        sut.selectedFilter = .upcoming
        XCTAssertEqual(sut.filteredFlights.count, 1)
        XCTAssertEqual(sut.filteredFlights.first?.id, "future")

        sut.selectedFilter = .past
        XCTAssertEqual(sut.filteredFlights.count, 1)
        XCTAssertEqual(sut.filteredFlights.first?.id, "past")
    }
}
