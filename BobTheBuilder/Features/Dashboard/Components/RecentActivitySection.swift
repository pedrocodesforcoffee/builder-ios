//
//  RecentActivitySection.swift
//  BobTheBuilder
//
//  Dashboard recent activity section component
//  Created on November 10, 2025.
//

import SwiftUI

struct RecentActivitySection: View {
    let activities: [Activity]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            Text("Recent Activity")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)

            if activities.isEmpty {
                EmptyActivityView()
            } else {
                VStack(spacing: 8) {
                    ForEach(activities.prefix(10)) { activity in
                        ActivityRow(activity: activity)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ActivityRow: View {
    let activity: Activity

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Activity Icon
            ZStack {
                Circle()
                    .fill(activity.activityType.color.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: activity.activityType.icon)
                    .font(.caption)
                    .foregroundColor(activity.activityType.color)
            }

            // Activity Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // User info
                    if let user = activity.user {
                        Text(user.fullName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    } else {
                        Text("System")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Timestamp
                    Text(activity.relativeTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Activity Type
                Text(activity.activityType.displayName)
                    .font(.caption)
                    .foregroundColor(activity.activityType.color)

                // Description
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Metadata
                if let metadata = activity.metadata {
                    VStack(alignment: .leading, spacing: 2) {
                        if let projectName = metadata.projectName {
                            HStack(spacing: 4) {
                                Image(systemName: "folder.fill")
                                    .font(.caption2)
                                Text(projectName)
                                    .font(.caption2)
                            }
                            .foregroundColor(.secondary)
                        }

                        if let orgName = metadata.organizationName {
                            HStack(spacing: 4) {
                                Image(systemName: "building.2.fill")
                                    .font(.caption2)
                                Text(orgName)
                                    .font(.caption2)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}

struct EmptyActivityView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))

            Text("No Recent Activity")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Activity will appear here when actions are performed")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct RecentActivitySection_Previews: PreviewProvider {
    static var previews: some View {
        RecentActivitySection(
            activities: [
                Activity(
                    id: "1",
                    type: "PROJECT_CREATED",
                    description: "Created a new project for downtown office complex",
                    user: ActivityUser(
                        id: "user1",
                        firstName: "John",
                        lastName: "Doe",
                        email: "john.doe@example.com",
                        avatar: nil
                    ),
                    entityType: "project",
                    entityId: "proj1",
                    metadata: ActivityMetadata(
                        projectName: "Downtown Office Complex",
                        organizationName: "Acme Construction",
                        changes: nil,
                        previousValue: nil,
                        newValue: nil
                    ),
                    createdAt: "2024-11-10T10:30:00Z"
                ),
                Activity(
                    id: "2",
                    type: "PROJECT_STATUS_CHANGED",
                    description: "Changed project status from Planning to Active",
                    user: ActivityUser(
                        id: "user2",
                        firstName: "Jane",
                        lastName: "Smith",
                        email: "jane.smith@example.com",
                        avatar: nil
                    ),
                    entityType: "project",
                    entityId: "proj1",
                    metadata: ActivityMetadata(
                        projectName: "Riverside Apartments",
                        organizationName: "Smith Engineering",
                        changes: nil,
                        previousValue: "PLANNING",
                        newValue: "ACTIVE"
                    ),
                    createdAt: "2024-11-10T09:15:00Z"
                )
            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
