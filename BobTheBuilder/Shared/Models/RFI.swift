//
//  RFI.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import Foundation
import SwiftUI

struct RFI: Identifiable, Codable {
    let id: String
    let number: String
    let subject: String
    let project: String
    let projectId: String
    let status: RFIStatus
    let priority: Priority
    let createdDate: Date
    let dueDate: Date?
    let description: String?

    enum RFIStatus: String, CaseIterable, Codable {
        case draft = "Draft"
        case pending = "Pending"
        case answered = "Answered"
        case closed = "Closed"

        var color: Color {
            switch self {
            case .draft: return .gray
            case .pending: return .orange
            case .answered: return .blue
            case .closed: return .green
            }
        }

        var icon: String {
            switch self {
            case .draft: return "doc"
            case .pending: return "clock"
            case .answered: return "checkmark.circle"
            case .closed: return "checkmark.circle.fill"
            }
        }
    }

    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"

        var color: Color {
            switch self {
            case .low: return .gray
            case .medium: return .blue
            case .high: return .orange
            case .critical: return .red
            }
        }

        var icon: String {
            switch self {
            case .low: return "minus.circle"
            case .medium: return "equal.circle"
            case .high: return "exclamationmark.circle"
            case .critical: return "exclamationmark.triangle.fill"
            }
        }
    }

    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && status != .closed
    }
}

// MARK: - Mock Data for Development

extension RFI {
    static var mockRFIs: [RFI] {
        [
            RFI(
                id: "1",
                number: "001",
                subject: "Clarification on foundation specifications",
                project: "Downtown Office Complex",
                projectId: "1",
                status: .pending,
                priority: .high,
                createdDate: Date().addingTimeInterval(-86400 * 3),
                dueDate: Date().addingTimeInterval(86400 * 2),
                description: "Need clarification on depth requirements for foundation piers in zone A."
            ),
            RFI(
                id: "2",
                number: "002",
                subject: "Material substitution request for exterior cladding",
                project: "Riverside Apartments",
                projectId: "2",
                status: .answered,
                priority: .medium,
                createdDate: Date().addingTimeInterval(-86400 * 7),
                dueDate: Date().addingTimeInterval(86400 * 5),
                description: "Request approval for alternative cladding material due to supply chain issues."
            ),
            RFI(
                id: "3",
                number: "003",
                subject: "HVAC system layout confirmation",
                project: "Shopping Center Renovation",
                projectId: "3",
                status: .closed,
                priority: .low,
                createdDate: Date().addingTimeInterval(-86400 * 14),
                dueDate: nil,
                description: "Confirm HVAC ductwork routing through structural members."
            ),
            RFI(
                id: "4",
                number: "004",
                subject: "Electrical panel capacity verification",
                project: "Downtown Office Complex",
                projectId: "1",
                status: .pending,
                priority: .critical,
                createdDate: Date().addingTimeInterval(-86400 * 1),
                dueDate: Date().addingTimeInterval(86400 * 1),
                description: "Verify electrical panel capacity meets updated load calculations."
            ),
            RFI(
                id: "5",
                number: "005",
                subject: "Window glazing specifications",
                project: "Riverside Apartments",
                projectId: "2",
                status: .draft,
                priority: .medium,
                createdDate: Date().addingTimeInterval(-86400 * 2),
                dueDate: Date().addingTimeInterval(86400 * 7),
                description: "Clarify glazing U-value requirements for north-facing windows."
            )
        ]
    }

    static var sample: RFI {
        mockRFIs[0]
    }
}
