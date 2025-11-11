//
//  NavigationPath.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI
import Combine

// Navigation destinations enum
enum NavigationDestination: Hashable, Codable {
    case projectDetail(projectId: String)
    case rfiDetail(rfiId: String)
    case createProject
    case createRFI(projectId: String)
    case profile
    case settings
    case about

    var id: String {
        switch self {
        case .projectDetail(let id): return "project_\(id)"
        case .rfiDetail(let id): return "rfi_\(id)"
        case .createProject: return "create_project"
        case .createRFI(let projectId): return "create_rfi_\(projectId)"
        case .profile: return "profile"
        case .settings: return "settings"
        case .about: return "about"
        }
    }

    /// Determines if this destination requires authentication
    var requiresAuthentication: Bool {
        switch self {
        case .projectDetail, .rfiDetail, .createProject, .createRFI:
            return true
        case .profile, .settings:
            return true
        case .about:
            return false
        }
    }
}

// Observable navigation state
@MainActor
class NavigationPathManager: ObservableObject {
    @Published var projectsPath: [NavigationDestination] = []
    @Published var rfisPath: [NavigationDestination] = []
    @Published var settingsPath: [NavigationDestination] = []
    @Published var selectedTab: TabItem = .projects

    // Auth-aware navigation state
    @Published var showingAuthRequired = false
    @Published var returnDestination: NavigationDestination?
    @Published var returnTab: TabItem?

    private var cancellables = Set<AnyCancellable>()
    private let authManager = AuthManager.shared

    static let shared = NavigationPathManager()

    private init() {
        setupNotifications()
    }

    private func setupNotifications() {
        // Reset navigation on logout
        NotificationCenter.default.publisher(for: .userLoggedOut)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleLogout()
            }
            .store(in: &cancellables)
    }

    private func handleLogout() {
        reset()
        returnDestination = nil
        returnTab = nil
        showingAuthRequired = false
    }

    func navigate(to destination: NavigationDestination, in tab: TabItem? = nil) {
        // Check if destination requires authentication
        if destination.requiresAuthentication && !authManager.isAuthenticated {
            print("⚠️ Navigation blocked: Authentication required for \(destination)")
            returnDestination = destination
            returnTab = tab ?? selectedTab
            showingAuthRequired = true
            return
        }

        // Navigate to destination
        if let tab = tab {
            selectedTab = tab
        }

        switch selectedTab {
        case .projects:
            projectsPath.append(destination)
        case .rfis:
            rfisPath.append(destination)
        case .settings:
            settingsPath.append(destination)
        }

        print("✅ Navigated to \(destination) in \(selectedTab)")
    }

    func popToRoot(in tab: TabItem? = nil) {
        let targetTab = tab ?? selectedTab

        switch targetTab {
        case .projects:
            projectsPath.removeAll()
        case .rfis:
            rfisPath.removeAll()
        case .settings:
            settingsPath.removeAll()
        }
    }

    func pop(in tab: TabItem? = nil) {
        let targetTab = tab ?? selectedTab

        switch targetTab {
        case .projects:
            if !projectsPath.isEmpty { projectsPath.removeLast() }
        case .rfis:
            if !rfisPath.isEmpty { rfisPath.removeLast() }
        case .settings:
            if !settingsPath.isEmpty { settingsPath.removeLast() }
        }
    }

    func reset() {
        projectsPath.removeAll()
        rfisPath.removeAll()
        settingsPath.removeAll()
        selectedTab = .projects
    }

    // MARK: - Auth-Aware Navigation

    /// Check if a destination requires authentication
    func requiresAuthentication(for destination: NavigationDestination) -> Bool {
        return destination.requiresAuthentication
    }

    /// Continue navigation after successful authentication
    func continueAfterAuth() {
        showingAuthRequired = false

        guard let destination = returnDestination else {
            print("ℹ️ No pending navigation to continue")
            return
        }

        print("🔄 Continuing navigation to \(destination) after authentication")

        // Navigate to the stored destination
        if let tab = returnTab {
            selectedTab = tab
        }

        switch selectedTab {
        case .projects:
            projectsPath.append(destination)
        case .rfis:
            rfisPath.append(destination)
        case .settings:
            settingsPath.append(destination)
        }

        // Clear stored destination
        returnDestination = nil
        returnTab = nil

        print("✅ Navigation completed to \(destination)")
    }

    /// Store a destination for navigation after authentication
    func storeForAfterAuth(destination: NavigationDestination, in tab: TabItem? = nil) {
        returnDestination = destination
        returnTab = tab
        showingAuthRequired = true
        print("📌 Stored \(destination) for navigation after authentication")
    }
}
