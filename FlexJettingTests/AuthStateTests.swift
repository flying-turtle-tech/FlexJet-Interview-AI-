import XCTest
@testable import FlexJetting

final class AuthStateTests: XCTestCase {

    // MARK: - Initial State

    func testInitialStateReflectsServiceAuthenticationStatus() async {
        await MainActor.run {
            let mockAuthService = MockAuthenticationService()
            mockAuthService.isAuthenticatedValue = true
            let authState = AuthState(authenticationService: mockAuthService)

            XCTAssertTrue(authState.isAuthenticated)
        }
    }

    func testInitialStateIsNotAuthenticatedWhenServiceIsNot() async {
        await MainActor.run {
            let mockAuthService = MockAuthenticationService()
            mockAuthService.isAuthenticatedValue = false
            let authState = AuthState(authenticationService: mockAuthService)

            XCTAssertFalse(authState.isAuthenticated)
        }
    }

    // MARK: - Sign In

    func testSignInUpdatesIsAuthenticatedOnSuccess() async throws {
        let (sut, _) = await createSUT()

        await MainActor.run {
            XCTAssertFalse(sut.isAuthenticated)
        }

        try await sut.signIn(username: "testuser", password: "password123")

        await MainActor.run {
            XCTAssertTrue(sut.isAuthenticated)
        }
    }

    func testSignInCallsServiceWithCredentials() async throws {
        let (sut, mockAuthService) = await createSUT()

        try await sut.signIn(username: "testuser", password: "password123")

        XCTAssertTrue(mockAuthService.signInCalled)
        XCTAssertEqual(mockAuthService.lastUsername, "testuser")
        XCTAssertEqual(mockAuthService.lastPassword, "password123")
    }

    func testSignInThrowsAndDoesNotAuthenticateOnError() async {
        let (sut, mockAuthService) = await createSUT()
        mockAuthService.signInError = NetworkError.unauthorized

        do {
            try await sut.signIn(username: "testuser", password: "password123")
            XCTFail("Expected error to be thrown")
        } catch {
            await MainActor.run {
                XCTAssertFalse(sut.isAuthenticated)
            }
        }
    }

    // MARK: - Sign Out

    func testSignOutUpdatesIsAuthenticated() async throws {
        let (sut, _) = await createSUT()

        try await sut.signIn(username: "testuser", password: "password123")
        await MainActor.run {
            XCTAssertTrue(sut.isAuthenticated)
            sut.signOut()
            XCTAssertFalse(sut.isAuthenticated)
        }
    }

    func testSignOutCallsService() async throws {
        let (sut, mockAuthService) = await createSUT()

        try await sut.signIn(username: "testuser", password: "password123")

        await MainActor.run {
            sut.signOut()
        }

        XCTAssertTrue(mockAuthService.signOutCalled)
    }

    func testSignOutRemainsAuthenticatedOnError() async throws {
        let (sut, mockAuthService) = await createSUT()

        try await sut.signIn(username: "testuser", password: "password123")
        mockAuthService.signOutError = KeychainError.deleteFailed(-1)

        await MainActor.run {
            sut.signOut()
            XCTAssertTrue(sut.isAuthenticated)
        }
    }

    // MARK: - Helpers

    @MainActor
    private func createSUT() -> (AuthState, MockAuthenticationService) {
        let mockAuthService = MockAuthenticationService()
        let sut = AuthState(authenticationService: mockAuthService)
        return (sut, mockAuthService)
    }
}
