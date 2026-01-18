import XCTest
@testable import FlexJetting

final class APIClientTests: XCTestCase {
    private var sut: URLSessionAPIClient!
    private var mockTokenStorage: MockTokenStorage!
    private var session: URLSession!

    override func setUp() {
        super.setUp()
        mockTokenStorage = MockTokenStorage()
        mockTokenStorage.storedToken = "test-token"

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)

        sut = URLSessionAPIClient(
            baseURL: URL(string: "https://api.example.com")!,
            session: session,
            tokenStorage: mockTokenStorage
        )
    }

    override func tearDown() {
        sut = nil
        mockTokenStorage = nil
        session = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    // MARK: - Date Decoding Tests

    func testDecodesISO8601DatesFromFlightResponse() async throws {
        let flightJSON = """
        [
            {
                "id": "FL001",
                "tripNumber": "1234567",
                "flightNumber": "UA890",
                "tailNumber": "N987UA",
                "origin": "Las Vegas (LAS)",
                "originIata": "LAS",
                "destination": "New York (JFK)",
                "destinationIata": "JFK",
                "departure": "2026-01-08T09:20:00.000Z",
                "arrival": "2026-01-08T12:20:00.000Z",
                "price": 10800
            }
        ]
        """

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, flightJSON.data(using: .utf8)!)
        }

        let endpoint = Endpoint(path: "api/flights", method: .get, requiresAuth: true)
        let flights = try await sut.request(endpoint: endpoint, responseType: [Flight].self)

        XCTAssertEqual(flights.count, 1)

        let flight = flights[0]

        // Verify departure date components
        let calendar = Calendar(identifier: .gregorian)
        var departureComponents = calendar.dateComponents(
            in: TimeZone(identifier: "UTC")!,
            from: flight.departure
        )
        XCTAssertEqual(departureComponents.year, 2026)
        XCTAssertEqual(departureComponents.month, 1)
        XCTAssertEqual(departureComponents.day, 8)
        XCTAssertEqual(departureComponents.hour, 9)
        XCTAssertEqual(departureComponents.minute, 20)
        XCTAssertEqual(departureComponents.second, 0)

        // Verify arrival date components
        var arrivalComponents = calendar.dateComponents(
            in: TimeZone(identifier: "UTC")!,
            from: flight.arrival
        )
        XCTAssertEqual(arrivalComponents.year, 2026)
        XCTAssertEqual(arrivalComponents.month, 1)
        XCTAssertEqual(arrivalComponents.day, 8)
        XCTAssertEqual(arrivalComponents.hour, 12)
        XCTAssertEqual(arrivalComponents.minute, 20)
        XCTAssertEqual(arrivalComponents.second, 0)
    }

    func testDecodesISO8601DatesWithoutMilliseconds() async throws {
        let flightJSON = """
        [
            {
                "id": "FL001",
                "tripNumber": "1234567",
                "tailNumber": "N987UA",
                "origin": "Las Vegas (LAS)",
                "originIata": "LAS",
                "destination": "New York (JFK)",
                "destinationIata": "JFK",
                "departure": "2026-01-08T09:20:00Z",
                "arrival": "2026-01-08T12:20:00Z",
                "price": 10800
            }
        ]
        """

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, flightJSON.data(using: .utf8)!)
        }

        let endpoint = Endpoint(path: "api/flights", method: .get, requiresAuth: true)
        let flights = try await sut.request(endpoint: endpoint, responseType: [Flight].self)

        XCTAssertEqual(flights.count, 1)
        XCTAssertNotNil(flights[0].departure)
        XCTAssertNotNil(flights[0].arrival)
    }

    func testDecodesFlightWithOptionalFlightNumber() async throws {
        let flightJSON = """
        [
            {
                "id": "FL001",
                "tripNumber": "1234567",
                "tailNumber": "N987UA",
                "origin": "Las Vegas (LAS)",
                "originIata": "LAS",
                "destination": "New York (JFK)",
                "destinationIata": "JFK",
                "departure": "2026-01-08T09:20:00.000Z",
                "arrival": "2026-01-08T12:20:00.000Z",
                "price": 10800
            }
        ]
        """

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, flightJSON.data(using: .utf8)!)
        }

        let endpoint = Endpoint(path: "api/flights", method: .get, requiresAuth: true)
        let flights = try await sut.request(endpoint: endpoint, responseType: [Flight].self)

        XCTAssertEqual(flights.count, 1)
        XCTAssertNil(flights[0].flightNumber)
    }

    // MARK: - Error Handling Tests

    func testThrowsTokenExpiredForExpiredTokenResponse() async throws {
        let errorJSON = """
        {
            "error": "Invalid or expired token"
        }
        """

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, errorJSON.data(using: .utf8)!)
        }

        let endpoint = Endpoint(path: "api/flights", method: .get, requiresAuth: true)

        do {
            _ = try await sut.request(endpoint: endpoint, responseType: [Flight].self)
            XCTFail("Expected tokenExpired error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .tokenExpired)
            XCTAssertTrue(error.isAuthenticationError)
        }
    }

    func testThrowsUnauthorizedForInvalidCredentials() async throws {
        let errorJSON = """
        {
            "error": "Invalid credentials"
        }
        """

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, errorJSON.data(using: .utf8)!)
        }

        let endpoint = Endpoint(path: "api/signIn", method: .post, requiresAuth: false)

        do {
            _ = try await sut.request(endpoint: endpoint, responseType: SignInResponse.self)
            XCTFail("Expected unauthorized error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .unauthorized)
            XCTAssertTrue(error.isAuthenticationError)
        }
    }

    func testThrowsUnauthorizedWhenNoTokenStored() async throws {
        mockTokenStorage.storedToken = nil

        let endpoint = Endpoint(path: "api/flights", method: .get, requiresAuth: true)

        do {
            _ = try await sut.request(endpoint: endpoint, responseType: [Flight].self)
            XCTFail("Expected unauthorized error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .unauthorized)
        }
    }

    func testThrowsDecodingFailedForInvalidJSON() async throws {
        let invalidJSON = "not valid json"

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidJSON.data(using: .utf8)!)
        }

        let endpoint = Endpoint(path: "api/flights", method: .get, requiresAuth: true)

        do {
            _ = try await sut.request(endpoint: endpoint, responseType: [Flight].self)
            XCTFail("Expected decodingFailed error")
        } catch let error as NetworkError {
            if case .decodingFailed = error {
                // Success
            } else {
                XCTFail("Expected decodingFailed error, got \(error)")
            }
        }
    }

    // MARK: - Request Configuration Tests

    func testAddsAuthorizationHeaderForAuthenticatedEndpoints() async throws {
        mockTokenStorage.storedToken = "my-auth-token"

        var capturedRequest: URLRequest?

        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, "[]".data(using: .utf8)!)
        }

        let endpoint = Endpoint(path: "api/flights", method: .get, requiresAuth: true)
        _ = try await sut.request(endpoint: endpoint, responseType: [Flight].self)

        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer my-auth-token")
    }

    func testDoesNotAddAuthorizationHeaderForUnauthenticatedEndpoints() async throws {
        var capturedRequest: URLRequest?

        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, "{\"token\": \"abc\"}".data(using: .utf8)!)
        }

        let endpoint = Endpoint(path: "api/signIn", method: .post, requiresAuth: false)
        _ = try await sut.request(endpoint: endpoint, responseType: SignInResponse.self)

        XCTAssertNil(capturedRequest?.value(forHTTPHeaderField: "Authorization"))
    }
}
