//
//  AuthManager.swift
//  BobTheBuilder
//
//  Created on November 9, 2025.
//

import Foundation
import Combine
import UIKit
import LocalAuthentication

enum AuthState {
    case unknown
    case authenticated(User)
    case unauthenticated
    case refreshing
}

enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case tokenRefreshFailed
    case sessionExpired
    case networkError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .tokenRefreshFailed:
            return "Failed to refresh session. Please login again."
        case .sessionExpired:
            return "Your session has expired. Please login again."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown:
            return "An unexpected error occurred"
        }
    }
}

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    // Published state
    @Published private(set) var authState: AuthState = .unknown
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated = false

    // Internal state
    private var refreshTask: Task<AuthTokens, Error>?
    private var refreshRetryCount = 0
    private let maxRefreshRetries = 3
    private var cancellables = Set<AnyCancellable>()

    // Dependencies
    private let tokenManager = TokenManager.shared
    private let apiClient: APIClientProtocol

    // Refresh timer
    private var tokenRefreshTimer: Timer?

    var isRefreshing: Bool {
        if case .refreshing = authState {
            return true
        }
        return false
    }

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
        setupSubscriptions()
        checkAuthenticationStatus()
    }

    // MARK: - Setup

    private func setupSubscriptions() {
        // Listen for token expiry notifications
        NotificationCenter.default.publisher(for: .tokenExpired)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    await self.handleTokenExpiry()
                }
            }
            .store(in: &cancellables)

        // Listen for 401 responses
        NotificationCenter.default.publisher(for: .unauthorizedResponse)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    await self.handleUnauthorizedResponse()
                }
            }
            .store(in: &cancellables)

        // Monitor app lifecycle for token refresh
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    await self.checkAndRefreshIfNeeded()
                }
            }
            .store(in: &cancellables)

        // Sync with TokenManager state
        tokenManager.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                self?.isAuthenticated = isAuthenticated
                if !isAuthenticated {
                    self?.authState = .unauthenticated
                }
            }
            .store(in: &cancellables)

        tokenManager.$currentUser
            .sink { [weak self] user in
                self?.currentUser = user
                if let user = user {
                    self?.authState = .authenticated(user)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Authentication Methods

    func login(email: String, password: String) async throws {
        print("🔐 Attempting login for: \(email)")

        do {
            let request = LoginAPIRequest(email: email, password: password)
            let response = try await apiClient.execute(request)

            // Save tokens
            try tokenManager.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                expiresIn: response.expiresIn,
                user: response.user
            )

            // Update state
            currentUser = response.user
            authState = .authenticated(response.user)
            isAuthenticated = true

            // Schedule token refresh
            scheduleTokenRefresh(expiresIn: response.expiresIn)

            print("✅ Login successful for: \(response.user.email)")

        } catch let error as APIError {
            print("❌ Login failed: \(error)")
            throw mapToAuthError(error)
        } catch {
            print("❌ Login failed with unknown error: \(error)")
            throw AuthError.unknown
        }
    }

    func logout() async {
        print("👋 Logging out user")

        // Cancel any pending refresh
        refreshTask?.cancel()
        tokenRefreshTimer?.invalidate()

        // Attempt to call logout endpoint
        do {
            let request = LogoutAPIRequest()
            _ = try await apiClient.execute(request)
            print("✅ Server logout successful")
        } catch {
            print("⚠️ Server logout failed, continuing with local logout: \(error)")
        }

        // Clear local state
        tokenManager.clearTokens()
        currentUser = nil
        authState = .unauthenticated
        isAuthenticated = false
        refreshRetryCount = 0

        // Post logout notification
        NotificationCenter.default.post(name: .userLoggedOut, object: nil)
    }

    func register(email: String, password: String, firstName: String, lastName: String) async throws {
        print("📝 Attempting registration for: \(email)")

        do {
            let request = RegisterAPIRequest(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
            let response = try await apiClient.execute(request)

            // Automatically login after registration
            try tokenManager.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                expiresIn: response.expiresIn,
                user: response.user
            )

            currentUser = response.user
            authState = .authenticated(response.user)
            isAuthenticated = true

            // Schedule token refresh
            scheduleTokenRefresh(expiresIn: response.expiresIn)

            print("✅ Registration successful for: \(response.user.email)")

        } catch let error as APIError {
            print("❌ Registration failed: \(error)")
            throw mapToAuthError(error)
        } catch {
            print("❌ Registration failed with unknown error: \(error)")
            throw AuthError.unknown
        }
    }

    // MARK: - Token Refresh

    func refreshTokens() async throws -> AuthTokens {
        print("🔄 Starting token refresh")

        // Prevent multiple simultaneous refresh attempts
        if let existingTask = refreshTask {
            print("⏳ Refresh already in progress, waiting...")
            return try await existingTask.value
        }

        // Create new refresh task
        let task = Task<AuthTokens, Error> {
            authState = .refreshing

            guard let refreshToken = tokenManager.getRefreshToken() else {
                print("❌ No refresh token available")
                throw AuthError.sessionExpired
            }

            do {
                let request = RefreshTokenAPIRequest(refreshToken: refreshToken)
                let response = try await apiClient.execute(request)

                // Update stored tokens
                try tokenManager.updateTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken,
                    expiresIn: response.expiresIn
                )

                // Reset retry count on success
                refreshRetryCount = 0

                // Update state
                if let user = currentUser {
                    authState = .authenticated(user)
                }

                // Schedule next refresh
                scheduleTokenRefresh(expiresIn: response.expiresIn)

                print("✅ Token refresh successful")

                let tokens = AuthTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken,
                    expiresIn: response.expiresIn
                )
                return tokens

            } catch {
                print("❌ Token refresh failed: \(error)")
                refreshRetryCount += 1

                if refreshRetryCount >= maxRefreshRetries {
                    print("❌ Max refresh retries reached, logging out")
                    await logout()
                    throw AuthError.tokenRefreshFailed
                }

                throw error
            }
        }

        refreshTask = task

        do {
            let tokens = try await task.value
            refreshTask = nil
            return tokens
        } catch {
            refreshTask = nil
            throw error
        }
    }

    private func checkAndRefreshIfNeeded() async {
        guard isAuthenticated else { return }

        // Check if token will expire soon (within 5 minutes)
        if let expiryDate = tokenManager.tokenExpiryDate() {
            let timeUntilExpiry = expiryDate.timeIntervalSinceNow

            if timeUntilExpiry < 300 { // 5 minutes
                print("⚠️ Token expiring soon, refreshing...")
                do {
                    _ = try await refreshTokens()
                } catch {
                    print("❌ Proactive refresh failed: \(error)")
                }
            }
        }
    }

    private func scheduleTokenRefresh(expiresIn: Int) {
        tokenRefreshTimer?.invalidate()

        // Schedule refresh for 30 seconds before expiry
        let refreshInterval = max(Double(expiresIn) - 30, 30)

        tokenRefreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: false) { _ in
            Task {
                await self.checkAndRefreshIfNeeded()
            }
        }

        print("⏰ Scheduled token refresh in \(refreshInterval) seconds")
    }

    // MARK: - Error Handling

    private func handleTokenExpiry() async {
        print("⚠️ Token expired, attempting refresh")

        do {
            _ = try await refreshTokens()
        } catch {
            print("❌ Failed to refresh after expiry: \(error)")
            await logout()
        }
    }

    private func handleUnauthorizedResponse() async {
        print("⚠️ Received 401, attempting refresh")

        // Don't retry if we're already refreshing
        guard !isRefreshing else { return }

        do {
            _ = try await refreshTokens()

            // Retry the failed request
            NotificationCenter.default.post(name: .tokenRefreshed, object: nil)

        } catch {
            print("❌ Failed to refresh after 401: \(error)")
            await logout()
        }
    }

    // MARK: - State Management

    func checkAuthenticationStatus() {
        if tokenManager.isAuthenticated,
           let user = tokenManager.currentUser {
            currentUser = user
            authState = .authenticated(user)
            isAuthenticated = true

            // Check if we need to refresh
            Task {
                await checkAndRefreshIfNeeded()
            }
        } else {
            authState = .unauthenticated
            isAuthenticated = false
        }
    }

    // MARK: - Biometric Authentication

    func loginWithBiometric(context: LAContext) async throws {
        guard let credentials = tokenManager.getSavedCredentials(context: context) else {
            throw AuthError.invalidCredentials
        }

        try await login(email: credentials.email, password: credentials.password)
    }

    func enableBiometric(email: String, password: String) throws {
        try tokenManager.enableBiometric(email: email, password: password)
    }

    func disableBiometric() {
        tokenManager.disableBiometric()
    }

    // MARK: - Helper Methods

    private func mapToAuthError(_ apiError: APIError) -> AuthError {
        switch apiError {
        case .unauthorized:
            return .invalidCredentials
        case .noInternetConnection, .networkError:
            return .networkError
        default:
            return .unknown
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let unauthorizedResponse = Notification.Name("unauthorizedResponse")
    static let tokenRefreshed = Notification.Name("tokenRefreshed")
}
