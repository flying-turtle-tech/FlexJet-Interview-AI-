import XCTest
@testable import FlexJetting

@MainActor
final class LoginViewModelTests: XCTestCase {
    private var sut: LoginViewModel!
    private var mockAuthState: AuthState!
    private var mockAuthService: MockAuthenticationService!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthenticationService()
        mockAuthState = AuthState(authenticationService: mockAuthService)
        sut = LoginViewModel(authState: mockAuthState)
    }

    override func tearDown() {
        sut = nil
        mockAuthState = nil
        mockAuthService = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialStateIsCorrect() {
        XCTAssertTrue(sut.username.isEmpty)
        XCTAssertTrue(sut.password.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Form Validation

    func testIsFormValidReturnsFalseWhenUsernameIsEmpty() {
        sut.username = ""
        sut.password = "password123"

        XCTAssertFalse(sut.isFormValid)
    }

    func testIsFormValidReturnsFalseWhenUsernameIsOnlyWhitespace() {
        sut.username = "   "
        sut.password = "password123"

        XCTAssertFalse(sut.isFormValid)
    }

    func testIsFormValidReturnsFalseWhenPasswordIsEmpty() {
        sut.username = "testuser"
        sut.password = ""

        XCTAssertFalse(sut.isFormValid)
    }

    func testIsFormValidReturnsTrueWhenBothFieldsHaveContent() {
        sut.username = "testuser"
        sut.password = "password123"

        XCTAssertTrue(sut.isFormValid)
    }

    func testIsFormValidReturnsTrueWhenUsernameHasLeadingWhitespace() {
        sut.username = "  testuser"
        sut.password = "password123"

        XCTAssertTrue(sut.isFormValid)
    }

    // MARK: - Sign In Success

    func testSignInSuccessUpdatesAuthState() async {
        sut.username = "testuser"
        sut.password = "password123"

        await sut.signIn()

        XCTAssertTrue(mockAuthService.signInCalled)
        XCTAssertTrue(mockAuthState.isAuthenticated)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testSignInTrimsUsernameWhitespace() async {
        sut.username = "  testuser  "
        sut.password = "password123"

        await sut.signIn()

        XCTAssertEqual(mockAuthService.lastUsername, "testuser")
    }

    func testSignInDoesNotTrimPassword() async {
        sut.username = "testuser"
        sut.password = "  password123  "

        await sut.signIn()

        XCTAssertEqual(mockAuthService.lastPassword, "  password123  ")
    }

    // MARK: - Sign In Failure

    func testSignInWithInvalidFormDoesNotCallService() async {
        sut.username = ""
        sut.password = ""

        await sut.signIn()

        XCTAssertFalse(mockAuthService.signInCalled)
    }

    func testSignInNetworkErrorSetsUserFacingMessage() async {
        sut.username = "testuser"
        sut.password = "password123"
        mockAuthService.signInError = NetworkError.unauthorized

        await sut.signIn()

        XCTAssertEqual(sut.errorMessage, NetworkError.unauthorized.userFacingMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testSignInUnknownErrorSetsGenericMessage() async {
        sut.username = "testuser"
        sut.password = "password123"
        mockAuthService.signInError = NSError(domain: "test", code: 1)

        await sut.signIn()

        XCTAssertEqual(sut.errorMessage, "An unexpected error occurred. Please try again.")
    }

    func testSignInClearsExistingError() async {
        sut.username = "testuser"
        sut.password = "password123"
        mockAuthService.signInError = NetworkError.unauthorized
        await sut.signIn()
        XCTAssertNotNil(sut.errorMessage)

        mockAuthService.signInError = nil
        await sut.signIn()

        XCTAssertNil(sut.errorMessage)
    }
}
