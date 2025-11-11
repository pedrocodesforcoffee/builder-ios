//
//  AppCoordinator.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var showOnboarding = false
    @Published var appError: AppError?
    @Published var requiresReauthentication = false

    private let navigationManager = NavigationPathManager.shared
    private let authManager = AuthManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var pendingDeepLink: NavigationDestination?
    private var sessionExpiryWorkItem: DispatchWorkItem?

    static let shared = AppCoordinator()

    private init() {
        setupBindings()
        checkInitialState()
    }

    private func setupBindings() {
        // Subscribe to auth manager state
        authManager.$authState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleAuthStateChange(state)
            }
            .store(in: &cancellables)

        // Listen for logout notification
        NotificationCenter.default.publisher(for: .userLoggedOut)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleLogout()
            }
            .store(in: &cancellables)

        // Listen for session expiry
        NotificationCenter.default.publisher(for: .tokenExpired)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleTokenExpiry()
            }
            .store(in: &cancellables)

        // Listen for token refreshed
        NotificationCenter.default.publisher(for: .tokenRefreshed)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleTokenRefreshed()
            }
            .store(in: &cancellables)

        // App lifecycle
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppBecameActive()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppWillResignActive()
            }
            .store(in: &cancellables)
    }

    private func checkInitialState() {
        Task {
            // Check authentication status
            authManager.checkAuthenticationStatus()

            // Small delay for smooth transition
            try? await Task.sleep(nanoseconds: 500_000_000)

            // Check onboarding
            let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

            await MainActor.run {
                self.showOnboarding = !hasSeenOnboarding && !authManager.isAuthenticated
                self.isLoading = false
            }
        }
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        showOnboarding = false
    }

    func logout() {
        Task {
            await authManager.logout()
        }
    }

    private func handleLogout() {
        isAuthenticated = false
        navigationManager.reset()

        // Show logout message
        appError = AppError(
            title: "Signed Out",
            message: "You have been signed out successfully.",
            dismissAction: nil
        )
    }

    // MARK: - Auth State Handling

    private func handleAuthStateChange(_ state: AuthState) {
        switch state {
        case .authenticated(let user):
            print("✅ User authenticated: \(user.email)")
            isAuthenticated = true
            requiresReauthentication = false

            // Process any pending deep links
            if let pendingDeepLink = pendingDeepLink {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigateToDestination(pendingDeepLink)
                    self.pendingDeepLink = nil
                }
            }

        case .unauthenticated:
            print("🚪 User unauthenticated")
            isAuthenticated = false
            requiresReauthentication = false
            navigationManager.reset()

        case .refreshing:
            print("🔄 Refreshing authentication")
            // Don't change navigation during refresh

        case .unknown:
            print("❓ Authentication state unknown")
            isAuthenticated = false
        }
    }

    private func handleTokenExpiry() {
        if !authManager.isRefreshing {
            requiresReauthentication = true
            appError = AppError(
                title: "Session Expired",
                message: "Your session has expired. Please sign in again.",
                dismissAction: {
                    self.requiresReauthentication = false
                }
            )
        }
    }

    private func handleTokenRefreshed() {
        requiresReauthentication = false
    }

    // MARK: - Deep Link Handling

    func handleDeepLink(_ url: URL) {
        print("🔗 Handling deep link: \(url)")

        guard let destination = parseDeepLink(url) else {
            print("❌ Failed to parse deep link")
            return
        }

        if isAuthenticated {
            navigateToDestination(destination)
        } else {
            // Store for after authentication
            pendingDeepLink = destination
            print("📌 Deep link saved for after authentication")
        }
    }

    private func parseDeepLink(_ url: URL) -> NavigationDestination? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }

        let pathComponents = components.path.split(separator: "/").map(String.init)

        switch components.host {
        case "project":
            if let projectId = pathComponents.first {
                return .projectDetail(projectId: projectId)
            }

        case "rfi":
            if let rfiId = pathComponents.first {
                return .rfiDetail(rfiId: rfiId)
            }

        case "settings":
            return .settings

        case "profile":
            return .profile

        default:
            break
        }

        return nil
    }

    private func navigateToDestination(_ destination: NavigationDestination) {
        // Determine which tab the destination belongs to
        let targetTab: TabItem

        switch destination {
        case .projectDetail, .createProject:
            targetTab = .projects
        case .rfiDetail, .createRFI:
            targetTab = .rfis
        case .settings, .profile, .about:
            targetTab = .settings
        }

        // Navigate
        navigationManager.navigate(to: destination, in: targetTab)
    }

    // MARK: - App Lifecycle

    private func handleAppBecameActive() {
        // Check if we need to refresh tokens
        if isAuthenticated {
            Task {
                // Note: checkAndRefreshIfNeeded doesn't exist yet, so we'll call it when available
                // await authManager.checkAndRefreshIfNeeded()
            }
        }

        // Cancel any pending session expiry
        sessionExpiryWorkItem?.cancel()
    }

    private func handleAppWillResignActive() {
        // Schedule session expiry check for 5 minutes
        sessionExpiryWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.handleSessionTimeout()
        }

        sessionExpiryWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 300, execute: workItem) // 5 minutes
    }

    private func handleSessionTimeout() {
        if isAuthenticated {
            requiresReauthentication = true
            appError = AppError(
                title: "Session Timeout",
                message: "Your session has timed out due to inactivity. Please sign in again.",
                dismissAction: { [weak self] in
                    self?.logout()
                }
            )
        }
    }

    // MARK: - Utilities

    func showMessage(title: String, message: String, dismissAction: (() -> Void)? = nil) {
        appError = AppError(
            title: title,
            message: message,
            dismissAction: dismissAction
        )
    }
}

struct AppError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let dismissAction: (() -> Void)?
}
