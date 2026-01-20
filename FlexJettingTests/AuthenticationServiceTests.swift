import XCTest
@testable import FlexJetting

final class AuthenticationServiceTests: XCTestCase {
    private var sut: DefaultAuthenticationService!
    private var mockAPIClient: MockAPIClient!
    private var mockTokenStorage: MockTokenStorage!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockTokenStorage = MockTokenStorage()
        sut = DefaultAuthenticationService(
            apiClient: mockAPIClient,
            tokenStorage: mockTokenStorage
        )
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        mockTokenStorage = nil
        super.tearDown()
    }

    // MARK: - isAuthenticated

    func testIsAuthenticatedReturnsTrueWhenTokenExists() {
        mockTokenStorage.storedToken = "valid-token"

        XCTAssertTrue(sut.isAuthenticated)
    }

    func testIsAuthenticatedReturnsFalseWhenNoToken() {
        mockTokenStorage.storedToken = nil

        XCTAssertFalse(sut.isAuthenticated)
    }

    // MARK: - Sign In

    func testSignInCallsAPIWithCorrectEndpoint() async throws {
        mockAPIClient.responseToReturn = SignInResponse(token: "new-token")

        try await sut.signIn(username: "testuser", password: "password123")

        XCTAssertTrue(mockAPIClient.requestCalled)
        XCTAssertEqual(mockAPIClient.lastEndpoint?.path, "api/signIn")
        XCTAssertEqual(mockAPIClient.lastEndpoint?.method, .post)
        XCTAssertEqual(mockAPIClient.lastEndpoint?.requiresAuth, false)
    }

    func testSignInSavesTokenOnSuccess() async throws {
        mockAPIClient.responseToReturn = SignInResponse(token: "new-token")

        try await sut.signIn(username: "testuser", password: "password123")
        XCTAssertEqual(mockTokenStorage.storedToken, "new-token")
    }

    func testSignInThrowsOnAPIError() async {
        mockAPIClient.errorToThrow = NetworkError.unauthorized

        do {
            try await sut.signIn(username: "testuser", password: "password123")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testSignInThrowsOnTokenSaveError() async {
        mockAPIClient.responseToReturn = SignInResponse(token: "new-token")
        mockTokenStorage.saveError = KeychainError.saveFailed(-1)

        do {
            try await sut.signIn(username: "testuser", password: "password123")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is KeychainError)
        }
    }

    // MARK: - Sign Out

    func testSignOutDeletesToken() throws {
        mockTokenStorage.storedToken = "existing-token"

        try sut.signOut()

        XCTAssertNil(mockTokenStorage.storedToken)
    }

    func testSignOutThrowsOnDeleteError() {
        mockTokenStorage.deleteError = KeychainError.deleteFailed(-1)

        XCTAssertThrowsError(try sut.signOut()) { error in
            XCTAssertTrue(error is KeychainError)
        }
    }
}
