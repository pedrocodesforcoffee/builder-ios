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

    private let navigationManager = NavigationPathManager.shared
    private var cancellables = Set<AnyCancellable>()

    static let shared = AppCoordinator()

    private init() {
        setupBindings()
        checkInitialState()
    }

    private func setupBindings() {
        // Future: Subscribe to auth state changes
        // Future: Subscribe to deep link events
    }

    private func checkInitialState() {
        Task {
            // Simulate loading delay
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

            // Check if user has seen onboarding
            let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

            // Check if user is authenticated (placeholder)
            let isUserAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")

            await MainActor.run {
                self.showOnboarding = !hasSeenOnboarding
                self.isAuthenticated = isUserAuthenticated
                self.isLoading = false
            }
        }
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        showOnboarding = false
    }

    func login() {
        // Placeholder for login logic
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        isAuthenticated = true
        navigationManager.reset()
    }

    func logout() {
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        isAuthenticated = false
        navigationManager.reset()
    }

    func handleDeepLink(_ url: URL) {
        // Parse URL and navigate accordingly
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }

        // Example deep link: bobthebuilder://project/123
        if components.host == "project",
           let projectId = components.path.split(separator: "/").last.map(String.init) {
            navigationManager.navigate(to: .projectDetail(projectId: projectId), in: .projects)
        }
    }
}

struct AppError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let dismissAction: (() -> Void)?
}
