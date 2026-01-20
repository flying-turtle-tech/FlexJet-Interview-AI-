import Foundation
import Security
import SwiftSecurity

protocol TokenStorage {
    func saveToken(_ token: String) throws
    func getToken() -> String?
    func deleteToken() throws
}

final class KeychainManager: TokenStorage {
    static let shared = KeychainManager()

    private let tokenKey = "authToken"
    private let keychain = Keychain.default
    
    private init() {}

    func saveToken(_ token: String) throws {
        try keychain.remove(.credential(for: tokenKey))
        try keychain.store(token, query: .credential(for: tokenKey))
    }

    func getToken() -> String? {
        try? keychain.retrieve(.credential(for: tokenKey))
    }

    func deleteToken() throws {
        try keychain.remove(.credential(for: tokenKey))
    }
}
