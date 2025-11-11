//
//  Organization.swift
//  BobTheBuilder
//
//  Created on November 10, 2025.
//

import Foundation
import SwiftUI

struct Organization: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let slug: String
    let type: String
    let logo: String?
    let description: String?
    let isActive: Bool
    let createdAt: String
    let updatedAt: String?

    // Additional fields that may come from API
    let memberCount: Int?
    let projectCount: Int?

    var initials: String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            let first = words[0].prefix(1)
            let second = words[1].prefix(1)
            return "\(first)\(second)".uppercased()
        } else if let first = words.first {
            return String(first.prefix(2)).uppercased()
        }
        return "OR"
    }

    var formattedType: String {
        type.replacingOccurrences(of: "_", with: " ").capitalized
    }

    var typeColor: Color {
        switch type.uppercased() {
        case let t where t.contains("GENERAL_CONTRACTOR"):
            return .blue
        case let t where t.contains("SUBCONTRACTOR"):
            return .green
        case let t where t.contains("OWNER"):
            return .purple
        case let t where t.contains("ARCHITECT"):
            return .orange
        case let t where t.contains("ENGINEER"):
            return .teal
        default:
            return .gray
        }
    }

    var typeIcon: String {
        switch type.uppercased() {
        case let t where t.contains("GENERAL_CONTRACTOR"):
            return "building.2.fill"
        case let t where t.contains("SUBCONTRACTOR"):
            return "hammer.fill"
        case let t where t.contains("OWNER"):
            return "person.fill"
        case let t where t.contains("ARCHITECT"):
            return "pencil.and.ruler.fill"
        case let t where t.contains("ENGINEER"):
            return "gearshape.fill"
        default:
            return "building.fill"
        }
    }
}
