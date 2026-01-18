import Foundation
import Security

protocol TokenStorage {
    func saveToken(_ token: String) throws
    func getToken() -> String?
    func deleteToken() throws
}

final class KeychainManager: TokenStorage {
    static let shared = KeychainManager()

    private let service = "com.flexjetting.auth"
    private let tokenKey = "authToken"

    private init() {}

    func saveToken(_ token: String) throws {
        try deleteToken()

        guard let data = token.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    func deleteToken() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

enum KeychainError: Error {
    case encodingFailed
    case saveFailed(OSStatus)
    case deleteFailed(OSStatus)

    var localizedDescription: String {
        switch self {
        case .encodingFailed:
            return "Failed to encode token data."
        case .saveFailed(let status):
            return "Failed to save to keychain (status: \(status))."
        case .deleteFailed(let status):
            return "Failed to delete from keychain (status: \(status))."
        }
    }
}
