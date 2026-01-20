import XCTest
@testable import FlexJetting

final class KeychainManagerTests: XCTestCase {
    private var sut: KeychainManager!

    override func setUp() {
        super.setUp()
        sut = KeychainManager.shared
        try? sut.deleteToken()
    }

    override func tearDown() {
        try? sut.deleteToken()
        sut = nil
        super.tearDown()
    }

    // MARK: - Save Token

    func testSaveTokenStoresTokenInKeychain() throws {
        try sut.saveToken("test-token")

        let retrieved = sut.getToken()
        XCTAssertEqual(retrieved, "test-token")
    }

    func testSaveTokenOverwritesExistingToken() throws {
        try sut.saveToken("first-token")
        try sut.saveToken("second-token")

        let retrieved = sut.getToken()
        XCTAssertEqual(retrieved, "second-token")
    }

    func testSaveTokenHandlesSpecialCharacters() throws {
        let specialToken = "token!@#$%^&*()_+-=[]{}|;':\",./<>?"
        try sut.saveToken(specialToken)

        let retrieved = sut.getToken()
        XCTAssertEqual(retrieved, specialToken)
    }

    func testSaveTokenHandlesLongTokens() throws {
        let longToken = String(repeating: "a", count: 10000)
        try sut.saveToken(longToken)

        let retrieved = sut.getToken()
        XCTAssertEqual(retrieved, longToken)
    }

    // MARK: - Get Token

    func testGetTokenReturnsNilWhenNoTokenStored() {
        let retrieved = sut.getToken()

        XCTAssertNil(retrieved)
    }

    func testGetTokenReturnsSavedToken() throws {
        try sut.saveToken("my-token")

        let retrieved = sut.getToken()

        XCTAssertEqual(retrieved, "my-token")
    }

    // MARK: - Delete Token

    func testDeleteTokenRemovesStoredToken() throws {
        try sut.saveToken("token-to-delete")

        try sut.deleteToken()

        XCTAssertNil(sut.getToken())
    }

    func testDeleteTokenSucceedsWhenNoTokenExists() throws {
        XCTAssertNoThrow(try sut.deleteToken())
    }

    func testDeleteTokenCanBeCalledMultipleTimes() throws {
        try sut.saveToken("token")
        try sut.deleteToken()

        XCTAssertNoThrow(try sut.deleteToken())
    }

    // MARK: - Token Lifecycle

    func testFullTokenLifecycle() throws {
        XCTAssertNil(sut.getToken())

        try sut.saveToken("lifecycle-token")
        XCTAssertEqual(sut.getToken(), "lifecycle-token")

        try sut.saveToken("updated-token")
        XCTAssertEqual(sut.getToken(), "updated-token")

        try sut.deleteToken()
        XCTAssertNil(sut.getToken())
    }
}
