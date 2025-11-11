//
//  KeychainService.swift
//  BobTheBuilder
//
//  Created on November 9, 2025.
//

import Foundation
import Security
import LocalAuthentication

enum KeychainError: LocalizedError {
    case itemNotFound
    case duplicateItem
    case invalidData
    case unhandledError(status: OSStatus)
    case biometricAuthenticationFailed

    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Item not found in keychain"
        case .duplicateItem:
            return "Item already exists in keychain"
        case .invalidData:
            return "Invalid data format"
        case .unhandledError(let status):
            return "Keychain error: \(status)"
        case .biometricAuthenticationFailed:
            return "Biometric authentication failed"
        }
    }
}

final class KeychainService {
    static let shared = KeychainService()

    private let serviceName = "com.bobthebuilder.app"
    private let accessGroup = "group.com.bobthebuilder.app"

    // Disable access group in simulator/debug to avoid keychain errors
    #if targetEnvironment(simulator) || DEBUG
    private let useAccessGroup = false
    #else
    private let useAccessGroup = true
    #endif

    private init() {}

    // MARK: - Generic Save/Load

    func save<T: Codable>(_ item: T,
                          key: String,
                          requiresBiometric: Bool = false) throws {
        let data = try JSONEncoder().encode(item)
        try saveData(data, key: key, requiresBiometric: requiresBiometric)
    }

    func load<T: Codable>(_ type: T.Type,
                          key: String,
                          context: LAContext? = nil) throws -> T {
        let data = try loadData(key: key, context: context)
        return try JSONDecoder().decode(type, from: data)
    }

    func delete(key: String) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        if useAccessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func deleteAll() throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]

        if useAccessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    // MARK: - Private Data Methods

    private func saveData(_ data: Data,
                         key: String,
                         requiresBiometric: Bool) throws {
        // Delete any existing item first
        try? delete(key: key)

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        if useAccessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        // Add biometric protection if required
        if requiresBiometric {
            let context = LAContext()
            context.touchIDAuthenticationAllowableReuseDuration = 10 // 10 seconds

            if let access = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .biometryCurrentSet,
                nil
            ) {
                query[kSecAttrAccessControl as String] = access
                query[kSecUseAuthenticationContext as String] = context
            }
        }

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            if status == errSecDuplicateItem {
                throw KeychainError.duplicateItem
            } else {
                throw KeychainError.unhandledError(status: status)
            }
        }
    }

    private func loadData(key: String, context: LAContext? = nil) throws -> Data {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        if useAccessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        // Use provided context for biometric authentication
        if let context = context {
            query[kSecUseAuthenticationContext as String] = context
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            } else if status == errSecUserCanceled {
                throw KeychainError.biometricAuthenticationFailed
            } else {
                throw KeychainError.unhandledError(status: status)
            }
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        return data
    }

    // MARK: - Convenience Methods

    func exists(key: String) -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]

        if useAccessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}
