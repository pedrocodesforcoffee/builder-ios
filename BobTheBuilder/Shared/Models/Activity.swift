//
//  Activity.swift
//  BobTheBuilder
//
//  Created on November 10, 2025.
//

import Foundation
import SwiftUI

struct Activity: Identifiable, Codable, Hashable {
    let id: String
    let type: String
    let description: String
    let user: ActivityUser?
    let entityType: String?
    let entityId: String?
    let metadata: ActivityMetadata?
    let createdAt: String

    var activityType: ActivityType {
        ActivityType(rawValue: type.uppercased()) ?? .other
    }

    var relativeTime: String {
        guard let date = createdAt.toDate() else {
            return "Unknown"
        }

        let now = Date()
        let interval = now.timeIntervalSince(date)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }

    var formattedDate: String {
        guard let date = createdAt.toDate() else {
            return "Unknown"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ActivityUser: Codable, Hashable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let avatar: String?

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var initials: String {
        let firstInitial = firstName.prefix(1)
        let lastInitial = lastName.prefix(1)
        return "\(firstInitial)\(lastInitial)".uppercased()
    }
}

struct ActivityMetadata: Codable, Hashable {
    let projectName: String?
    let organizationName: String?
    let changes: [String: String]?
    let previousValue: String?
    let newValue: String?
}

enum ActivityType: String, Codable {
    case projectCreated = "PROJECT_CREATED"
    case projectUpdated = "PROJECT_UPDATED"
    case projectStatusChanged = "PROJECT_STATUS_CHANGED"
    case projectDeleted = "PROJECT_DELETED"
    case memberAdded = "MEMBER_ADDED"
    case memberRemoved = "MEMBER_REMOVED"
    case memberRoleChanged = "MEMBER_ROLE_CHANGED"
    case documentUploaded = "DOCUMENT_UPLOADED"
    case documentDeleted = "DOCUMENT_DELETED"
    case commentAdded = "COMMENT_ADDED"
    case taskCreated = "TASK_CREATED"
    case taskCompleted = "TASK_COMPLETED"
    case taskAssigned = "TASK_ASSIGNED"
    case organizationCreated = "ORGANIZATION_CREATED"
    case organizationUpdated = "ORGANIZATION_UPDATED"
    case other = "OTHER"

    var displayName: String {
        switch self {
        case .projectCreated:
            return "Project Created"
        case .projectUpdated:
            return "Project Updated"
        case .projectStatusChanged:
            return "Status Changed"
        case .projectDeleted:
            return "Project Deleted"
        case .memberAdded:
            return "Member Added"
        case .memberRemoved:
            return "Member Removed"
        case .memberRoleChanged:
            return "Role Changed"
        case .documentUploaded:
            return "Document Uploaded"
        case .documentDeleted:
            return "Document Deleted"
        case .commentAdded:
            return "Comment Added"
        case .taskCreated:
            return "Task Created"
        case .taskCompleted:
            return "Task Completed"
        case .taskAssigned:
            return "Task Assigned"
        case .organizationCreated:
            return "Organization Created"
        case .organizationUpdated:
            return "Organization Updated"
        case .other:
            return "Activity"
        }
    }

    var icon: String {
        switch self {
        case .projectCreated:
            return "folder.badge.plus"
        case .projectUpdated:
            return "folder.badge.gearshape"
        case .projectStatusChanged:
            return "arrow.triangle.2.circlepath"
        case .projectDeleted:
            return "folder.badge.minus"
        case .memberAdded:
            return "person.badge.plus"
        case .memberRemoved:
            return "person.badge.minus"
        case .memberRoleChanged:
            return "person.badge.key"
        case .documentUploaded:
            return "doc.badge.plus"
        case .documentDeleted:
            return "doc.badge.minus"
        case .commentAdded:
            return "bubble.left"
        case .taskCreated:
            return "checkmark.circle.badge.plus"
        case .taskCompleted:
            return "checkmark.circle.fill"
        case .taskAssigned:
            return "person.crop.circle.badge.checkmark"
        case .organizationCreated:
            return "building.2"
        case .organizationUpdated:
            return "building.2.fill"
        case .other:
            return "app.badge"
        }
    }

    var color: Color {
        switch self {
        case .projectCreated, .memberAdded, .documentUploaded, .taskCreated, .organizationCreated:
            return .green
        case .projectUpdated, .projectStatusChanged, .memberRoleChanged, .organizationUpdated:
            return .blue
        case .projectDeleted, .memberRemoved, .documentDeleted:
            return .red
        case .commentAdded:
            return .purple
        case .taskCompleted:
            return .green
        case .taskAssigned:
            return .orange
        case .other:
            return .gray
        }
    }
}
