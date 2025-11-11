//
//  StatisticsCardsView.swift
//  BobTheBuilder
//
//  Dashboard statistics cards component
//  Created on November 10, 2025.
//

import SwiftUI

struct StatisticsCardsView: View {
    let projectStats: ProjectStatistics
    let organizationStats: OrganizationStatistics

    var body: some View {
        VStack(spacing: 16) {
            // Project Statistics Row
            HStack(spacing: 12) {
                StatCard(
                    title: "Total Projects",
                    value: "\(projectStats.total)",
                    icon: "folder.fill",
                    color: .blue
                )

                StatCard(
                    title: "Active",
                    value: "\(projectStats.active)",
                    icon: "play.circle.fill",
                    color: .green
                )
            }

            HStack(spacing: 12) {
                StatCard(
                    title: "Completed",
                    value: "\(projectStats.completed)",
                    icon: "checkmark.circle.fill",
                    color: .gray
                )

                StatCard(
                    title: "On Hold",
                    value: "\(projectStats.onHold)",
                    icon: "pause.circle.fill",
                    color: .orange
                )
            }

            // Organization Statistics Row
            HStack(spacing: 12) {
                StatCard(
                    title: "Organizations",
                    value: "\(organizationStats.total)",
                    icon: "building.2.fill",
                    color: .purple
                )

                StatCard(
                    title: "Team Members",
                    value: "\(organizationStats.totalMembers)",
                    icon: "person.3.fill",
                    color: .teal
                )
            }
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct StatisticsCardsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsCardsView(
            projectStats: ProjectStatistics(
                total: 15,
                active: 8,
                completed: 5,
                onHold: 2
            ),
            organizationStats: OrganizationStatistics(
                total: 3,
                active: 3,
                totalMembers: 24,
                totalProjects: 15
            )
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
