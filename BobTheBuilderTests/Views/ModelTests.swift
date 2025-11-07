//
//  ModelTests.swift
//  BobTheBuilderTests
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import XCTest
import SwiftUI
@testable import Bob_Dev

class ProjectTests: XCTestCase {

    // MARK: - Project Status Tests

    func testProjectStatusColors() {
        XCTAssertEqual(Project.ProjectStatus.planning.color, Color.blue)
        XCTAssertEqual(Project.ProjectStatus.active.color, Color.green)
        XCTAssertEqual(Project.ProjectStatus.onHold.color, Color.orange)
        XCTAssertEqual(Project.ProjectStatus.completed.color, Color.gray)
    }

    func testProjectStatusIcons() {
        XCTAssertEqual(Project.ProjectStatus.planning.icon, "lightbulb")
        XCTAssertEqual(Project.ProjectStatus.active.icon, "hammer.fill")
        XCTAssertEqual(Project.ProjectStatus.onHold.icon, "pause.circle")
        XCTAssertEqual(Project.ProjectStatus.completed.icon, "checkmark.circle")
    }

    func testProjectStatusRawValues() {
        XCTAssertEqual(Project.ProjectStatus.planning.rawValue, "Planning")
        XCTAssertEqual(Project.ProjectStatus.active.rawValue, "Active")
        XCTAssertEqual(Project.ProjectStatus.onHold.rawValue, "On Hold")
        XCTAssertEqual(Project.ProjectStatus.completed.rawValue, "Completed")
    }

    func testProjectStatusCaseIterable() {
        let allStatuses = Project.ProjectStatus.allCases
        XCTAssertEqual(allStatuses.count, 4)
        XCTAssertTrue(allStatuses.contains(.planning))
        XCTAssertTrue(allStatuses.contains(.active))
        XCTAssertTrue(allStatuses.contains(.onHold))
        XCTAssertTrue(allStatuses.contains(.completed))
    }

    // MARK: - Project Mock Data Tests

    func testMockProjects() {
        let mockProjects = Project.mockProjects

        XCTAssertEqual(mockProjects.count, 4)
        XCTAssertFalse(mockProjects.isEmpty)

        // Test first project
        let firstProject = mockProjects[0]
        XCTAssertEqual(firstProject.name, "Downtown Office Complex")
        XCTAssertEqual(firstProject.status, .active)
        XCTAssertEqual(firstProject.progress, 0.65)
        XCTAssertNotNil(firstProject.location)
        XCTAssertNotNil(firstProject.dueDate)
    }

    func testProjectSample() {
        let sample = Project.sample
        XCTAssertEqual(sample.id, "1")
        XCTAssertEqual(sample.name, "Downtown Office Complex")
    }

    func testProjectCodable() throws {
        let project = Project.sample
        let encoder = JSONEncoder()
        let data = try encoder.encode(project)

        let decoder = JSONDecoder()
        let decodedProject = try decoder.decode(Project.self, from: data)

        XCTAssertEqual(project.id, decodedProject.id)
        XCTAssertEqual(project.name, decodedProject.name)
        XCTAssertEqual(project.status, decodedProject.status)
        XCTAssertEqual(project.progress, decodedProject.progress)
    }
}

class RFITests: XCTestCase {

    // MARK: - RFI Status Tests

    func testRFIStatusColors() {
        XCTAssertEqual(RFI.RFIStatus.draft.color, Color.gray)
        XCTAssertEqual(RFI.RFIStatus.pending.color, Color.orange)
        XCTAssertEqual(RFI.RFIStatus.answered.color, Color.blue)
        XCTAssertEqual(RFI.RFIStatus.closed.color, Color.green)
    }

    func testRFIStatusIcons() {
        XCTAssertEqual(RFI.RFIStatus.draft.icon, "doc")
        XCTAssertEqual(RFI.RFIStatus.pending.icon, "clock")
        XCTAssertEqual(RFI.RFIStatus.answered.icon, "checkmark.circle")
        XCTAssertEqual(RFI.RFIStatus.closed.icon, "checkmark.circle.fill")
    }

    func testRFIStatusRawValues() {
        XCTAssertEqual(RFI.RFIStatus.draft.rawValue, "Draft")
        XCTAssertEqual(RFI.RFIStatus.pending.rawValue, "Pending")
        XCTAssertEqual(RFI.RFIStatus.answered.rawValue, "Answered")
        XCTAssertEqual(RFI.RFIStatus.closed.rawValue, "Closed")
    }

    // MARK: - RFI Priority Tests

    func testRFIPriorityColors() {
        XCTAssertEqual(RFI.Priority.low.color, Color.gray)
        XCTAssertEqual(RFI.Priority.medium.color, Color.blue)
        XCTAssertEqual(RFI.Priority.high.color, Color.orange)
        XCTAssertEqual(RFI.Priority.critical.color, Color.red)
    }

    func testRFIPriorityIcons() {
        XCTAssertEqual(RFI.Priority.low.icon, "minus.circle")
        XCTAssertEqual(RFI.Priority.medium.icon, "equal.circle")
        XCTAssertEqual(RFI.Priority.high.icon, "exclamationmark.circle")
        XCTAssertEqual(RFI.Priority.critical.icon, "exclamationmark.triangle.fill")
    }

    func testRFIPriorityRawValues() {
        XCTAssertEqual(RFI.Priority.low.rawValue, "Low")
        XCTAssertEqual(RFI.Priority.medium.rawValue, "Medium")
        XCTAssertEqual(RFI.Priority.high.rawValue, "High")
        XCTAssertEqual(RFI.Priority.critical.rawValue, "Critical")
    }

    // MARK: - RFI isOverdue Tests

    func testRFINotOverdueWhenNoDueDate() {
        let rfi = RFI(
            id: "1",
            number: "001",
            subject: "Test",
            project: "Test Project",
            projectId: "1",
            status: .pending,
            priority: .medium,
            createdDate: Date(),
            dueDate: nil,
            description: nil
        )

        XCTAssertFalse(rfi.isOverdue)
    }

    func testRFIOverdueWhenPastDueDate() {
        let pastDate = Date().addingTimeInterval(-86400) // 1 day ago
        let rfi = RFI(
            id: "1",
            number: "001",
            subject: "Test",
            project: "Test Project",
            projectId: "1",
            status: .pending,
            priority: .high,
            createdDate: Date().addingTimeInterval(-172800),
            dueDate: pastDate,
            description: nil
        )

        XCTAssertTrue(rfi.isOverdue)
    }

    func testRFINotOverdueWhenFutureDueDate() {
        let futureDate = Date().addingTimeInterval(86400) // 1 day from now
        let rfi = RFI(
            id: "1",
            number: "001",
            subject: "Test",
            project: "Test Project",
            projectId: "1",
            status: .pending,
            priority: .medium,
            createdDate: Date(),
            dueDate: futureDate,
            description: nil
        )

        XCTAssertFalse(rfi.isOverdue)
    }

    func testRFINotOverdueWhenClosed() {
        let pastDate = Date().addingTimeInterval(-86400) // 1 day ago
        let rfi = RFI(
            id: "1",
            number: "001",
            subject: "Test",
            project: "Test Project",
            projectId: "1",
            status: .closed,
            priority: .high,
            createdDate: Date().addingTimeInterval(-172800),
            dueDate: pastDate,
            description: nil
        )

        XCTAssertFalse(rfi.isOverdue)
    }

    // MARK: - RFI Mock Data Tests

    func testMockRFIs() {
        let mockRFIs = RFI.mockRFIs

        XCTAssertEqual(mockRFIs.count, 5)
        XCTAssertFalse(mockRFIs.isEmpty)

        // Test that we have different statuses
        let statuses = Set(mockRFIs.map { $0.status })
        XCTAssertTrue(statuses.count > 1)

        // Test that we have different priorities
        let priorities = Set(mockRFIs.map { $0.priority })
        XCTAssertTrue(priorities.count > 1)
    }

    func testRFISample() {
        let sample = RFI.sample
        XCTAssertEqual(sample.id, "1")
        XCTAssertEqual(sample.number, "001")
        XCTAssertEqual(sample.status, .pending)
        XCTAssertEqual(sample.priority, .high)
    }

    func testRFICodable() throws {
        let rfi = RFI.sample
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(rfi)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedRFI = try decoder.decode(RFI.self, from: data)

        XCTAssertEqual(rfi.id, decodedRFI.id)
        XCTAssertEqual(rfi.number, decodedRFI.number)
        XCTAssertEqual(rfi.subject, decodedRFI.subject)
        XCTAssertEqual(rfi.status, decodedRFI.status)
        XCTAssertEqual(rfi.priority, decodedRFI.priority)
    }
}
