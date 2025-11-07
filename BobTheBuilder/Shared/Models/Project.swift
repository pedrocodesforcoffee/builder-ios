//
//  Project.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import Foundation
import SwiftUI

struct Project: Identifiable, Codable {
    let id: String
    let name: String
    let status: ProjectStatus
    let progress: Double
    let dueDate: Date?
    let location: String?
    let description: String?

    enum ProjectStatus: String, CaseIterable, Codable {
        case planning = "Planning"
        case active = "Active"
        case onHold = "On Hold"
        case completed = "Completed"

        var color: Color {
            switch self {
            case .planning: return .blue
            case .active: return .green
            case .onHold: return .orange
            case .completed: return .gray
            }
        }

        var icon: String {
            switch self {
            case .planning: return "lightbulb"
            case .active: return "hammer.fill"
            case .onHold: return "pause.circle"
            case .completed: return "checkmark.circle"
            }
        }
    }
}

// MARK: - Mock Data for Development

extension Project {
    static var mockProjects: [Project] {
        [
            Project(
                id: "1",
                name: "Downtown Office Complex",
                status: .active,
                progress: 0.65,
                dueDate: Date().addingTimeInterval(86400 * 30),
                location: "123 Main St, Downtown",
                description: "Modern 15-story office building with retail space"
            ),
            Project(
                id: "2",
                name: "Riverside Apartments",
                status: .planning,
                progress: 0.15,
                dueDate: Date().addingTimeInterval(86400 * 90),
                location: "456 River Rd",
                description: "Luxury residential complex with 200 units"
            ),
            Project(
                id: "3",
                name: "Shopping Center Renovation",
                status: .onHold,
                progress: 0.40,
                dueDate: nil,
                location: "789 Mall Ave",
                description: "Complete renovation of existing shopping center"
            ),
            Project(
                id: "4",
                name: "City Hall Restoration",
                status: .completed,
                progress: 1.0,
                dueDate: Date().addingTimeInterval(-86400 * 10),
                location: "City Center",
                description: "Historical restoration project"
            )
        ]
    }

    static var sample: Project {
        mockProjects[0]
    }
}
