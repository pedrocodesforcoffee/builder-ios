//
//  RoleBadgeView.swift
//  BobTheBuilder
//
//  Created on November 10, 2025.
//

import SwiftUI

/// Displays a role badge with appropriate color coding
struct RoleBadgeView: View {
    let role: String
    let size: BadgeSize

    init(role: String, size: BadgeSize = .medium) {
        self.role = role
        self.size = size
    }

    var body: some View {
        Text(formattedRole)
            .font(size.font)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(roleColor.opacity(0.2))
            .foregroundColor(roleColor)
            .cornerRadius(size.cornerRadius)
    }

    private var formattedRole: String {
        role.replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    private var roleColor: Color {
        if role.contains("GENERAL_CONTRACTOR") {
            return .blue
        } else if role.contains("SUBCONTRACTOR") {
            return .green
        } else if role.contains("OWNER") || role.contains("PROJECT_OWNER") {
            return .purple
        } else if role.contains("ARCHITECT") {
            return .orange
        } else if role.contains("ENGINEER") {
            return .teal
        } else if role.contains("SAFETY") {
            return .red
        } else if role.contains("QUALITY") {
            return .red
        } else if role.contains("ADMIN") {
            return .indigo
        } else {
            return .gray
        }
    }
}

/// Badge size configuration
enum BadgeSize {
    case small, medium, large

    var font: Font {
        switch self {
        case .small: return .caption2
        case .medium: return .caption
        case .large: return .subheadline
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 6
        case .medium: return 8
        case .large: return 12
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .small: return 2
        case .medium: return 4
        case .large: return 6
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 6
        case .large: return 8
        }
    }
}

// MARK: - Previews

struct RoleBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            RoleBadgeView(role: "GENERAL_CONTRACTOR_ADMIN", size: .small)
            RoleBadgeView(role: "SUBCONTRACTOR_FOREMAN", size: .medium)
            RoleBadgeView(role: "PROJECT_OWNER", size: .large)
            RoleBadgeView(role: "ARCHITECT", size: .medium)
            RoleBadgeView(role: "ENGINEER", size: .medium)
        }
        .padding()
    }
}
