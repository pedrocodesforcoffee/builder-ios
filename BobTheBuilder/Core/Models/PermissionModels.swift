//
//  PermissionModels.swift
//  BobTheBuilder
//
//  Core permission models and types for multi-level RBAC system
//

import Foundation
import SwiftUI

// MARK: - Project Role

enum ProjectRole: String, Codable, CaseIterable, Identifiable {
    case projectAdmin = "PROJECT_ADMIN"
    case projectManager = "PROJECT_MANAGER"
    case projectEngineer = "PROJECT_ENGINEER"
    case superintendent = "SUPERINTENDENT"
    case foreman = "FOREMAN"
    case architectEngineer = "ARCHITECT_ENGINEER"
    case subcontractor = "SUBCONTRACTOR"
    case ownerRep = "OWNER_REP"
    case inspector = "INSPECTOR"
    case viewer = "VIEWER"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .projectAdmin: return "Project Admin"
        case .projectManager: return "Project Manager"
        case .projectEngineer: return "Project Engineer"
        case .superintendent: return "Superintendent"
        case .foreman: return "Foreman"
        case .architectEngineer: return "Architect/Engineer"
        case .subcontractor: return "Subcontractor"
        case .ownerRep: return "Owner's Rep"
        case .inspector: return "Inspector"
        case .viewer: return "Viewer"
        }
    }

    var icon: String {
        switch self {
        case .projectAdmin: return "crown.fill"
        case .projectManager: return "person.badge.key.fill"
        case .projectEngineer: return "wrench.and.screwdriver.fill"
        case .superintendent: return "hammer.fill"
        case .foreman: return "person.2.fill"
        case .architectEngineer: return "ruler.fill"
        case .subcontractor: return "building.2.fill"
        case .ownerRep: return "briefcase.fill"
        case .inspector: return "checkmark.shield.fill"
        case .viewer: return "eye.fill"
        }
    }

    var color: Color {
        switch self {
        case .projectAdmin: return .purple
        case .projectManager: return .blue
        case .projectEngineer: return .orange
        case .superintendent: return .green
        case .foreman: return .teal
        case .architectEngineer: return .indigo
        case .subcontractor: return .brown
        case .ownerRep: return .red
        case .inspector: return .mint
        case .viewer: return .gray
        }
    }

    var description: String {
        switch self {
        case .projectAdmin:
            return "Complete project access including settings and permissions"
        case .projectManager:
            return "Full project management without permission changes"
        case .projectEngineer:
            return "Technical documentation and RFI management"
        case .superintendent:
            return "Field operations and daily reports"
        case .foreman:
            return "Work area-specific operations (scope required)"
        case .architectEngineer:
            return "Design review and technical consultation"
        case .subcontractor:
            return "Trade-specific access (scope required)"
        case .ownerRep:
            return "View all, approve milestones and budgets"
        case .inspector:
            return "Compliance reporting and inspections"
        case .viewer:
            return "Read-only access to assigned data"
        }
    }

    var requiresScope: Bool {
        switch self {
        case .foreman, .subcontractor:
            return true
        default:
            return false
        }
    }
}

// MARK: - User Scope

struct UserScope: Codable, Equatable, Hashable {
    let trades: [String]?
    let areas: [String]?
    let phases: [String]?

    var isEmpty: Bool {
        (trades?.isEmpty ?? true) &&
        (areas?.isEmpty ?? true) &&
        (phases?.isEmpty ?? true)
    }

    var totalItems: Int {
        (trades?.count ?? 0) + (areas?.count ?? 0) + (phases?.count ?? 0)
    }

    func isInScope(itemId: String, type: ScopeType) -> Bool {
        switch type {
        case .trade:
            guard let trades = trades, !trades.isEmpty else { return true }
            return trades.contains(itemId)
        case .area:
            guard let areas = areas, !areas.isEmpty else { return true }
            return areas.contains(itemId)
        case .phase:
            guard let phases = phases, !phases.isEmpty else { return true }
            return phases.contains(itemId)
        }
    }
}

enum ScopeType: String {
    case trade = "trade"
    case area = "area"
    case phase = "phase"
}

// MARK: - Permission Response

struct PermissionResponse: Codable {
    let permissions: [String: Bool]
    let role: ProjectRole
    let scope: UserScope?
    let expiresAt: Date?

    enum CodingKeys: String, CodingKey {
        case permissions, role, scope
        case expiresAt = "expires_at"
    }
}

// MARK: - Project Member

struct ProjectMember: Identifiable, Codable, Hashable {
    let id: String
    let user: User
    let role: ProjectRole
    let scope: UserScope?
    let expiresAt: Date?
    let expirationReason: String?
    let joinedAt: Date
    let invitedBy: User?
    let isInherited: Bool

    enum CodingKeys: String, CodingKey {
        case id, user, role, scope
        case expiresAt = "expires_at"
        case expirationReason = "expiration_reason"
        case joinedAt = "joined_at"
        case invitedBy = "invited_by"
        case isInherited = "is_inherited"
    }

    var daysUntilExpiration: Int? {
        guard let expiresAt = expiresAt else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day
        return days
    }

    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }

    var isExpiringSoon: Bool {
        guard let days = daysUntilExpiration else { return false }
        return days > 0 && days <= 7
    }
}

// MARK: - User

struct User: Identifiable, Codable, Hashable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let company: String?
    let avatarURL: URL?

    var name: String {
        "\(firstName) \(lastName)"
    }

    var initials: String {
        let first = firstName.prefix(1)
        let last = lastName.prefix(1)
        return "\(first)\(last)".uppercased()
    }

    enum CodingKeys: String, CodingKey {
        case id, email, company
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarURL = "avatar_url"
    }
}

// MARK: - Cached Permissions

struct CachedPermissions: Codable {
    let permissions: [String: Bool]
    let role: ProjectRole
    let scope: UserScope?
    let expiresAt: Date?
    let cachedAt: Date

    var isStale: Bool {
        let fiveMinutes: TimeInterval = 5 * 60
        return Date().timeIntervalSince(cachedAt) > fiveMinutes
    }
}
