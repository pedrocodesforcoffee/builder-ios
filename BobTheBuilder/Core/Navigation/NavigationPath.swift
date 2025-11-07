//
//  NavigationPath.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

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
}

// Observable navigation state
@MainActor
class NavigationPathManager: ObservableObject {
    @Published var projectsPath: [NavigationDestination] = []
    @Published var rfisPath: [NavigationDestination] = []
    @Published var settingsPath: [NavigationDestination] = []
    @Published var selectedTab: TabItem = .projects

    static let shared = NavigationPathManager()

    private init() {}

    func navigate(to destination: NavigationDestination, in tab: TabItem? = nil) {
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
}
