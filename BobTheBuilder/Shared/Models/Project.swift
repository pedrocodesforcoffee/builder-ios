//
//  Project.swift
//  BobTheBuilder
//
//  Created on November 10, 2025.
//

import Foundation
import SwiftUI

struct Project: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let code: String
    let description: String?
    let status: String
    let startDate: String?
    let endDate: String?
    let actualCompletionDate: String?
    let location: String?
    let organizationId: String
    let organizationName: String?
    let createdAt: String
    let updatedAt: String?

    // Project settings
    let settings: ProjectSettings?

    var statusEnum: ProjectStatus {
        ProjectStatus(rawValue: status.uppercased()) ?? .planning
    }

    var progress: Double {
        guard let start = startDate?.toDate(),
              let end = endDate?.toDate() else {
            return 0
        }

        let now = Date()
        guard now > start else { return 0 }
        guard now < end else { return 100 }

        let totalDuration = end.timeIntervalSince(start)
        let elapsed = now.timeIntervalSince(start)

        let progress = (elapsed / totalDuration) * 100
        return min(max(progress, 0), 100)
    }

    var daysRemaining: Int? {
        guard let end = endDate?.toDate() else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: end).day
        return days
    }

    var isOverdue: Bool {
        guard let end = endDate?.toDate() else { return false }
        return Date() > end && statusEnum != .completed
    }
}

struct ProjectSettings: Codable, Hashable {
    let budget: Double?
    let currency: String?
    let timezone: String?
}

enum ProjectStatus: String, Codable {
    case planning = "PLANNING"
    case active = "ACTIVE"
    case onHold = "ON_HOLD"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"

    var displayName: String {
        switch self {
        case .planning: return "Planning"
        case .active: return "Active"
        case .onHold: return "On Hold"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }

    var color: Color {
        switch self {
        case .planning: return .blue
        case .active: return .green
        case .onHold: return .orange
        case .completed: return .gray
        case .cancelled: return .red
        }
    }

    var icon: String {
        switch self {
        case .planning: return "calendar"
        case .active: return "play.circle.fill"
        case .onHold: return "pause.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
}

// MARK: - Extensions

extension String {
    func toDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: self)
    }

    func toFormattedDate() -> String? {
        guard let date = self.toDate() else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
