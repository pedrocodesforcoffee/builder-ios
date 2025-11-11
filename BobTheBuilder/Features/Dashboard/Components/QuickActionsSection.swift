//
//  QuickActionsSection.swift
//  BobTheBuilder
//
//  Dashboard quick actions section component
//  Created on November 10, 2025.
//

import SwiftUI

struct QuickActionsSection: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var navigationManager = NavigationPathManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            Text("Quick Actions")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)

            // Actions Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(availableActions) { action in
                    QuickActionCard(action: action)
                        .onTapGesture {
                            handleAction(action)
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    private var availableActions: [QuickAction] {
        var actions: [QuickAction] = []

        // Common actions for all users
        actions.append(QuickAction(
            id: "projects",
            title: "View Projects",
            icon: "folder.fill",
            color: .blue,
            action: .navigateToProjects
        ))

        actions.append(QuickAction(
            id: "organizations",
            title: "Organizations",
            icon: "building.2.fill",
            color: .purple,
            action: .navigateToOrganizations
        ))

        // Role-based actions
        if let primaryRole = authManager.currentUser?.primaryRole {
            if primaryRole.contains("ADMIN") || primaryRole.contains("OWNER") || primaryRole.contains("PROJECT_MANAGER") {
                actions.append(QuickAction(
                    id: "create-project",
                    title: "Create Project",
                    icon: "plus.circle.fill",
                    color: .green,
                    action: .createProject
                ))

                actions.append(QuickAction(
                    id: "reports",
                    title: "View Reports",
                    icon: "chart.bar.fill",
                    color: .orange,
                    action: .viewReports
                ))
            }

            if primaryRole.contains("ADMIN") {
                actions.append(QuickAction(
                    id: "manage-team",
                    title: "Manage Team",
                    icon: "person.3.fill",
                    color: .teal,
                    action: .manageTeam
                ))
            }
        }

        actions.append(QuickAction(
            id: "documents",
            title: "Documents",
            icon: "doc.fill",
            color: .indigo,
            action: .viewDocuments
        ))

        actions.append(QuickAction(
            id: "settings",
            title: "Settings",
            icon: "gearshape.fill",
            color: .gray,
            action: .navigateToSettings
        ))

        return actions
    }

    private func handleAction(_ action: QuickAction) {
        switch action.action {
        case .navigateToProjects:
            navigationManager.navigate(to: .projects)
        case .navigateToOrganizations:
            navigationManager.navigate(to: .organizations)
        case .navigateToSettings:
            navigationManager.navigate(to: .settings)
        case .createProject:
            // TODO: Implement create project flow
            print("Create Project tapped")
        case .viewReports:
            // TODO: Implement reports view
            print("View Reports tapped")
        case .manageTeam:
            // TODO: Implement team management
            print("Manage Team tapped")
        case .viewDocuments:
            // TODO: Implement documents view
            print("View Documents tapped")
        }
    }
}

struct QuickActionCard: View {
    let action: QuickAction

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: action.icon)
                .font(.system(size: 32))
                .foregroundColor(action.color)

            Text(action.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Models

struct QuickAction: Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let action: QuickActionType
}

enum QuickActionType {
    case navigateToProjects
    case navigateToOrganizations
    case navigateToSettings
    case createProject
    case viewReports
    case manageTeam
    case viewDocuments
}

struct QuickActionsSection_Previews: PreviewProvider {
    static var previews: some View {
        QuickActionsSection()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
