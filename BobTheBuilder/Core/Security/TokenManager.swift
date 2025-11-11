//
//  TokenManager.swift
//  BobTheBuilder
//
//  Created on November 9, 2025.
//

import Foundation
import Combine
import LocalAuthentication

// Token storage keys
enum TokenKey: String {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case tokenExpiry = "token_expiry"
    case user = "current_user"
    case biometricEnabled = "biometric_enabled"
    case savedCredentials = "saved_credentials"
}

// Saved credentials for biometric login
struct SavedCredentials: Codable {
    let email: String
    let password: String
    let savedAt: Date
}

@MainActor
final class TokenManager: ObservableObject {
    static let shared = TokenManager()

    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated = false
    @Published var isBiometricEnabled = false

    private let keychain = KeychainService.shared
    private var tokenExpiryTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadStoredData()
        setupBiometricPreference()
    }

    // MARK: - Token Management

    func saveTokens(accessToken: String, refreshToken: String, expiresIn: Int, user: User) throws {
        // Save access token
        try keychain.save(accessToken,
                         key: TokenKey.accessToken.rawValue,
                         requiresBiometric: false)

        // Save refresh token with biometric protection if enabled
        try keychain.save(refreshToken,
                         key: TokenKey.refreshToken.rawValue,
                         requiresBiometric: isBiometricEnabled)

        // Calculate and save expiry time
        let expiryDate = Date().addingTimeInterval(TimeInterval(expiresIn))
        try keychain.save(expiryDate,
                         key: TokenKey.tokenExpiry.rawValue,
                         requiresBiometric: false)

        // Save user information
        try keychain.save(user,
                         key: TokenKey.user.rawValue,
                         requiresBiometric: false)

        // Update published properties
        self.currentUser = user
        self.isAuthenticated = true

        // Start token expiry timer
        startTokenExpiryTimer(expiryDate: expiryDate)

        print("✅ Tokens saved successfully to Keychain")
    }

    nonisolated func getAccessToken() -> String? {
        do {
            let token: String = try keychain.load(String.self,
                                                  key: TokenKey.accessToken.rawValue)

            // Check if token is expired
            if let expiryDate = try? keychain.load(Date.self,
                                                   key: TokenKey.tokenExpiry.rawValue),
               expiryDate > Date() {
                return token
            } else {
                print("⚠️ Access token expired")
                return nil
            }
        } catch {
            print("❌ Failed to get access token: \(error.localizedDescription)")
            return nil
        }
    }

    nonisolated func getRefreshToken(context: LAContext? = nil) -> String? {
        do {
            let token: String = try keychain.load(String.self,
                                                  key: TokenKey.refreshToken.rawValue,
                                                  context: context)
            return token
        } catch {
            print("❌ Failed to get refresh token: \(error.localizedDescription)")
            return nil
        }
    }

    func updateTokens(accessToken: String, refreshToken: String, expiresIn: Int) throws {
        // Update access token
        try keychain.save(accessToken,
                         key: TokenKey.accessToken.rawValue,
                         requiresBiometric: false)

        // Update refresh token if provided
        if !refreshToken.isEmpty {
            try keychain.save(refreshToken,
                             key: TokenKey.refreshToken.rawValue,
                             requiresBiometric: isBiometricEnabled)
        }

        // Update expiry time
        let expiryDate = Date().addingTimeInterval(TimeInterval(expiresIn))
        try keychain.save(expiryDate,
                         key: TokenKey.tokenExpiry.rawValue,
                         requiresBiometric: false)

        // Restart timer
        startTokenExpiryTimer(expiryDate: expiryDate)

        print("✅ Tokens updated successfully")
    }

    func clearTokens() {
        do {
            try keychain.delete(key: TokenKey.accessToken.rawValue)
            try keychain.delete(key: TokenKey.refreshToken.rawValue)
            try keychain.delete(key: TokenKey.tokenExpiry.rawValue)
            try keychain.delete(key: TokenKey.user.rawValue)

            currentUser = nil
            isAuthenticated = false

            tokenExpiryTimer?.invalidate()
            tokenExpiryTimer = nil

            print("✅ Tokens cleared from Keychain")
        } catch {
            print("❌ Failed to clear tokens: \(error.localizedDescription)")
        }
    }

    // MARK: - Biometric Management

    func enableBiometric(email: String, password: String) throws {
        let credentials = SavedCredentials(
            email: email,
            password: password,
            savedAt: Date()
        )

        try keychain.save(credentials,
                         key: TokenKey.savedCredentials.rawValue,
                         requiresBiometric: true)

        UserDefaults.standard.set(true, forKey: TokenKey.biometricEnabled.rawValue)
        isBiometricEnabled = true

        print("✅ Biometric authentication enabled")
    }

    func disableBiometric() {
        do {
            try keychain.delete(key: TokenKey.savedCredentials.rawValue)
            UserDefaults.standard.set(false, forKey: TokenKey.biometricEnabled.rawValue)
            isBiometricEnabled = false

            print("✅ Biometric authentication disabled")
        } catch {
            print("❌ Failed to disable biometric: \(error.localizedDescription)")
        }
    }

    nonisolated func getSavedCredentials(context: LAContext) -> SavedCredentials? {
        do {
            let credentials: SavedCredentials = try keychain.load(
                SavedCredentials.self,
                key: TokenKey.savedCredentials.rawValue,
                context: context
            )
            return credentials
        } catch {
            print("❌ Failed to get saved credentials: \(error.localizedDescription)")
            return nil
        }
    }

    nonisolated func hasSavedCredentials() -> Bool {
        return keychain.exists(key: TokenKey.savedCredentials.rawValue)
    }

    // MARK: - Token Validation

    nonisolated func isTokenValid() -> Bool {
        guard let _ = getAccessToken() else { return false }

        do {
            if let expiryDate = try? keychain.load(Date.self,
                                                   key: TokenKey.tokenExpiry.rawValue) {
                return expiryDate > Date()
            }
        }

        return false
    }

    nonisolated func tokenExpiryDate() -> Date? {
        do {
            return try keychain.load(Date.self,
                                    key: TokenKey.tokenExpiry.rawValue)
        } catch {
            return nil
        }
    }

    // MARK: - Private Methods

    private func loadStoredData() {
        do {
            if let user = try? keychain.load(User.self,
                                            key: TokenKey.user.rawValue) {
                self.currentUser = user
                self.isAuthenticated = isTokenValid()

                // Start expiry timer if token exists
                if let expiryDate = tokenExpiryDate() {
                    startTokenExpiryTimer(expiryDate: expiryDate)
                }

                print("✅ Loaded user from Keychain: \(user.email)")
            }
        }
    }

    private func setupBiometricPreference() {
        isBiometricEnabled = UserDefaults.standard.bool(
            forKey: TokenKey.biometricEnabled.rawValue
        )
    }

    private func startTokenExpiryTimer(expiryDate: Date) {
        tokenExpiryTimer?.invalidate()

        let timeInterval = expiryDate.timeIntervalSinceNow
        if timeInterval > 0 {
            tokenExpiryTimer = Timer.scheduledTimer(withTimeInterval: timeInterval,
                                                   repeats: false) { _ in
                Task { @MainActor in
                    self.handleTokenExpiry()
                }
            }
        }
    }

    private func handleTokenExpiry() {
        print("⚠️ Token expired, need to refresh")
        NotificationCenter.default.post(name: .tokenExpired, object: nil)
    }
}

// Notification names
extension Notification.Name {
    static let tokenExpired = Notification.Name("tokenExpired")
    static let userLoggedOut = Notification.Name("userLoggedOut")
}
