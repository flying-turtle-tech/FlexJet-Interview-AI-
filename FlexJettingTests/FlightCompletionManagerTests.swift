import XCTest
@testable import FlexJetting

final class FlightCompletionManagerTests: XCTestCase {
    private let testKey = "completedFlightIds"

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: testKey)
    }

    // MARK: - Initial State

    func testInitialStateHasNoCompletedFlights() async {
        await MainActor.run {
            UserDefaults.standard.removeObject(forKey: testKey)
            let sut = FlightCompletionManager()
            XCTAssertTrue(sut.completedFlightIds.isEmpty)
        }
    }

    func testLoadsExistingCompletedFlightsFromUserDefaults() async {
        await MainActor.run {
            let existingIds: Set<String> = ["flight-1", "flight-2"]
            let data = try! JSONEncoder().encode(existingIds)
            UserDefaults.standard.set(data, forKey: testKey)

            let manager = FlightCompletionManager()

            XCTAssertEqual(manager.completedFlightIds, existingIds)
        }
    }

    // MARK: - isCompleted

    func testIsCompletedReturnsFalseForUncompletedFlight() async {
        let sut = await createSUT()
        await MainActor.run {
            XCTAssertFalse(sut.isCompleted("flight-1"))
        }
    }

    func testIsCompletedReturnsTrueForCompletedFlight() async {
        let sut = await createSUT()
        await MainActor.run {
            sut.toggle("flight-1")
            XCTAssertTrue(sut.isCompleted("flight-1"))
        }
    }

    // MARK: - Toggle

    func testToggleAddsFlightToCompleted() async {
        let sut = await createSUT()
        await MainActor.run {
            sut.toggle("flight-1")
            XCTAssertTrue(sut.completedFlightIds.contains("flight-1"))
        }
    }

    func testToggleRemovesFlightFromCompleted() async {
        let sut = await createSUT()
        await MainActor.run {
            sut.toggle("flight-1")
            XCTAssertTrue(sut.isCompleted("flight-1"))

            sut.toggle("flight-1")
            XCTAssertFalse(sut.isCompleted("flight-1"))
        }
    }

    func testTogglePersistsToUserDefaults() async {
        let sut = await createSUT()
        await MainActor.run {
            sut.toggle("flight-1")

            let data = UserDefaults.standard.data(forKey: testKey)
            let savedIds = try! JSONDecoder().decode(Set<String>.self, from: data!)

            XCTAssertTrue(savedIds.contains("flight-1"))
        }
    }

    func testToggleRemovalPersistsToUserDefaults() async {
        let sut = await createSUT()
        await MainActor.run {
            sut.toggle("flight-1")
            sut.toggle("flight-1")

            let data = UserDefaults.standard.data(forKey: testKey)
            let savedIds = try! JSONDecoder().decode(Set<String>.self, from: data!)

            XCTAssertFalse(savedIds.contains("flight-1"))
        }
    }

    // MARK: - Multiple Flights

    func testCanTrackMultipleCompletedFlights() async {
        let sut = await createSUT()
        await MainActor.run {
            sut.toggle("flight-1")
            sut.toggle("flight-2")
            sut.toggle("flight-3")

            XCTAssertEqual(sut.completedFlightIds.count, 3)
            XCTAssertTrue(sut.isCompleted("flight-1"))
            XCTAssertTrue(sut.isCompleted("flight-2"))
            XCTAssertTrue(sut.isCompleted("flight-3"))
        }
    }

    func testToggleOneFlightDoesNotAffectOthers() async {
        let sut = await createSUT()
        await MainActor.run {
            sut.toggle("flight-1")
            sut.toggle("flight-2")
            sut.toggle("flight-1")

            XCTAssertFalse(sut.isCompleted("flight-1"))
            XCTAssertTrue(sut.isCompleted("flight-2"))
        }
    }

    // MARK: - Helpers

    @MainActor
    private func createSUT() -> FlightCompletionManager {
        UserDefaults.standard.removeObject(forKey: testKey)
        return FlightCompletionManager()
    }
}
