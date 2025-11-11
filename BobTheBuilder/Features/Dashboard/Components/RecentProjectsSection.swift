//
//  RecentProjectsSection.swift
//  BobTheBuilder
//
//  Dashboard recent projects section component
//  Created on November 10, 2025.
//

import SwiftUI

struct RecentProjectsSection: View {
    let projects: [Project]
    @StateObject private var navigationManager = NavigationPathManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Text("Recent Projects")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                if !projects.isEmpty {
                    Button(action: {
                        navigationManager.navigate(to: .projects)
                    }) {
                        Text("See All")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)

            if projects.isEmpty {
                EmptyProjectsView()
            } else {
                VStack(spacing: 12) {
                    ForEach(projects.prefix(5)) { project in
                        DashboardProjectRow(project: project)
                            .onTapGesture {
                                navigationManager.navigate(to: .projectDetail(projectId: project.id))
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct DashboardProjectRow: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if let orgName = project.organizationName {
                        Text(orgName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Status Badge
                HStack(spacing: 4) {
                    Image(systemName: project.statusEnum.icon)
                        .font(.caption)
                    Text(project.statusEnum.displayName)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(project.statusEnum.color.opacity(0.2))
                .foregroundColor(project.statusEnum.color)
                .cornerRadius(6)
            }

            // Project Details
            HStack(spacing: 16) {
                if let location = project.location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                if let code = project.code as String? {
                    HStack(spacing: 4) {
                        Image(systemName: "number")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(code)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }

            // Progress Bar
            if project.statusEnum == .active || project.statusEnum == .onHold {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        if let daysRemaining = project.daysRemaining {
                            if daysRemaining > 0 {
                                Text("\(daysRemaining) days left")
                                    .font(.caption)
                                    .foregroundColor(daysRemaining < 7 ? .orange : .secondary)
                            } else {
                                Text("Overdue")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)

                            // Progress
                            RoundedRectangle(cornerRadius: 4)
                                .fill(progressColor)
                                .frame(width: geometry.size.width * CGFloat(project.progress / 100), height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text("\(Int(project.progress))% complete")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Budget (if available)
            if let settings = project.settings, let budget = settings.budget {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text(formatBudget(budget, currency: settings.currency))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }

    private var progressColor: Color {
        if project.isOverdue {
            return .red
        } else if let daysRemaining = project.daysRemaining, daysRemaining < 7 {
            return .orange
        } else {
            return .blue
        }
    }

    private func formatBudget(_ budget: Double, currency: String?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency ?? "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: budget)) ?? "\(Int(budget))"
    }
}

struct EmptyProjectsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))

            Text("No Projects")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("You don't have any projects yet")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct RecentProjectsSection_Previews: PreviewProvider {
    static var previews: some View {
        RecentProjectsSection(
            projects: [
                Project(
                    id: "1",
                    name: "Downtown Office Complex",
                    code: "DOC-2024-001",
                    description: "Modern office building",
                    status: "ACTIVE",
                    startDate: "2024-01-01T00:00:00Z",
                    endDate: "2024-12-31T00:00:00Z",
                    actualCompletionDate: nil,
                    location: "123 Main St, City",
                    organizationId: "org1",
                    organizationName: "Acme Construction",
                    createdAt: "2024-01-01T00:00:00Z",
                    updatedAt: nil,
                    settings: ProjectSettings(budget: 2500000, currency: "USD", timezone: "America/New_York")
                )
            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
