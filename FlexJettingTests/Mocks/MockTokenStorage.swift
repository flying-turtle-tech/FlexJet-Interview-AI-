import Foundation
@testable import FlexJetting

final class MockTokenStorage: TokenStorage {
    var storedToken: String?
    var saveError: Error?
    var deleteError: Error?

    func saveToken(_ token: String) throws {
        if let error = saveError {
            throw error
        }
        storedToken = token
    }

    func getToken() -> String? {
        storedToken
    }

    func deleteToken() throws {
        if let error = deleteError {
            throw error
        }
        storedToken = nil
    }
}
