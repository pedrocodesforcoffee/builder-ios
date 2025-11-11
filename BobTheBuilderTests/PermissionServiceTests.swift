//
//  PermissionServiceTests.swift
//  BobTheBuilderTests
//
//  Unit tests for PermissionService
//

import XCTest
@testable import BobTheBuilder

@MainActor
final class PermissionServiceTests: XCTestCase {
    var sut: PermissionService!
    var mockAPIClient: MockAPIClient!
    var cacheService: PermissionCacheService!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        cacheService = PermissionCacheService.shared
        sut = PermissionService(apiClient: mockAPIClient, cacheService: cacheService)
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        cacheService.clearAllCaches()
        super.tearDown()
    }

    // MARK: - Permission Checking Tests

    func testHasPermission_WhenPermissionExists_ReturnsTrue() {
        // Given
        sut.permissions = [
            "documents:drawing:read": true,
            "documents:drawing:create": false
        ]

        // When & Then
        XCTAssertTrue(sut.hasPermission("documents:drawing:read"))
        XCTAssertFalse(sut.hasPermission("documents:drawing:create"))
    }

    func testHasPermission_WhenPermissionDoesNotExist_ReturnsFalse() {
        // Given
        sut.permissions = [:]

        // When & Then
        XCTAssertFalse(sut.hasPermission("documents:drawing:read"))
    }

    func testHasAnyPermission_WhenAtLeastOneExists_ReturnsTrue() {
        // Given
        sut.permissions = [
            "documents:drawing:read": true,
            "documents:drawing:create": false
        ]

        // When & Then
        XCTAssertTrue(sut.hasAnyPermission([
            "documents:drawing:create",
            "documents:drawing:read"
        ]))
    }

    func testHasAnyPermission_WhenNoneExist_ReturnsFalse() {
        // Given
        sut.permissions = [
            "documents:drawing:read": true
        ]

        // When & Then
        XCTAssertFalse(sut.hasAnyPermission([
            "documents:drawing:create",
            "documents:drawing:delete"
        ]))
    }

    func testHasAllPermissions_WhenAllExist_ReturnsTrue() {
        // Given
        sut.permissions = [
            "documents:drawing:read": true,
            "documents:drawing:create": true,
            "documents:drawing:update": true
        ]

        // When & Then
        XCTAssertTrue(sut.hasAllPermissions([
            "documents:drawing:read",
            "documents:drawing:create"
        ]))
    }

    func testHasAllPermissions_WhenOneMissing_ReturnsFalse() {
        // Given
        sut.permissions = [
            "documents:drawing:read": true,
            "documents:drawing:create": false
        ]

        // When & Then
        XCTAssertFalse(sut.hasAllPermissions([
            "documents:drawing:read",
            "documents:drawing:create"
        ]))
    }

    // MARK: - Role Checking Tests

    func testHasRole_WhenRoleMatches_ReturnsTrue() {
        // Given
        sut.userRole = .projectManager

        // When & Then
        XCTAssertTrue(sut.hasRole(.projectManager))
        XCTAssertFalse(sut.hasRole(.projectAdmin))
    }

    func testHasAnyRole_WhenRoleInList_ReturnsTrue() {
        // Given
        sut.userRole = .projectManager

        // When & Then
        XCTAssertTrue(sut.hasAnyRole([.projectAdmin, .projectManager]))
        XCTAssertFalse(sut.hasAnyRole([.projectAdmin, .superintendent]))
    }

    // MARK: - Expiration Tests

    func testIsExpired_WhenDateInPast_ReturnsTrue() {
        // Given
        sut.expiresAt = Date().addingTimeInterval(-86400) // Yesterday

        // When & Then
        XCTAssertTrue(sut.isExpired)
    }

    func testIsExpired_WhenDateInFuture_ReturnsFalse() {
        // Given
        sut.expiresAt = Date().addingTimeInterval(86400) // Tomorrow

        // When & Then
        XCTAssertFalse(sut.isExpired)
    }

    func testIsExpired_WhenNoExpiration_ReturnsFalse() {
        // Given
        sut.expiresAt = nil

        // When & Then
        XCTAssertFalse(sut.isExpired)
    }

    func testIsExpiringSoon_WhenWithinThreshold_ReturnsTrue() {
        // Given
        sut.expiresAt = Date().addingTimeInterval(5 * 86400) // 5 days from now

        // When & Then
        XCTAssertTrue(sut.isExpiringSoon(threshold: 7))
        XCTAssertFalse(sut.isExpiringSoon(threshold: 3))
    }

    func testDaysUntilExpiration_ReturnsCorrectValue() {
        // Given
        sut.expiresAt = Date().addingTimeInterval(10 * 86400) // 10 days from now

        // When
        let days = sut.daysUntilExpiration

        // Then
        XCTAssertEqual(days, 10, accuracy: 1)
    }

    func testDaysUntilExpiration_WhenNoExpiration_ReturnsNil() {
        // Given
        sut.expiresAt = nil

        // When & Then
        XCTAssertNil(sut.daysUntilExpiration)
    }

    // MARK: - Scope Tests

    func testHasScope_WhenScopeExists_ReturnsTrue() {
        // Given
        sut.scope = UserScope(
            trades: ["Electrical"],
            areas: nil,
            phases: nil
        )

        // When & Then
        XCTAssertTrue(sut.hasScope)
    }

    func testHasScope_WhenScopeEmpty_ReturnsFalse() {
        // Given
        sut.scope = UserScope(trades: nil, areas: nil, phases: nil)

        // When & Then
        XCTAssertFalse(sut.hasScope)
    }

    func testIsInScope_WhenNoScope_ReturnsTrue() {
        // Given
        sut.scope = nil

        // When & Then
        XCTAssertTrue(sut.isInScope(itemId: "any", type: .trade))
    }

    func testIsInScope_WhenInScope_ReturnsTrue() {
        // Given
        sut.scope = UserScope(
            trades: ["Electrical", "Plumbing"],
            areas: nil,
            phases: nil
        )

        // When & Then
        XCTAssertTrue(sut.isInScope(itemId: "Electrical", type: .trade))
        XCTAssertFalse(sut.isInScope(itemId: "HVAC", type: .trade))
    }

    // MARK: - Reset Tests

    func testReset_ClearsAllState() {
        // Given
        sut.permissions = ["test": true]
        sut.userRole = .projectManager
        sut.scope = UserScope(trades: ["Test"], areas: nil, phases: nil)
        sut.expiresAt = Date()

        // When
        sut.reset()

        // Then
        XCTAssertTrue(sut.permissions.isEmpty)
        XCTAssertNil(sut.userRole)
        XCTAssertNil(sut.scope)
        XCTAssertNil(sut.expiresAt)
        XCTAssertNil(sut.error)
    }
}

// MARK: - UserScope Tests

final class UserScopeTests: XCTestCase {
    func testIsEmpty_WhenAllNil_ReturnsTrue() {
        // Given
        let scope = UserScope(trades: nil, areas: nil, phases: nil)

        // When & Then
        XCTAssertTrue(scope.isEmpty)
    }

    func testIsEmpty_WhenAllEmpty_ReturnsTrue() {
        // Given
        let scope = UserScope(trades: [], areas: [], phases: [])

        // When & Then
        XCTAssertTrue(scope.isEmpty)
    }

    func testIsEmpty_WhenHasItems_ReturnsFalse() {
        // Given
        let scope = UserScope(trades: ["Electrical"], areas: nil, phases: nil)

        // When & Then
        XCTAssertFalse(scope.isEmpty)
    }

    func testIsInScope_WithMatchingItem_ReturnsTrue() {
        // Given
        let scope = UserScope(
            trades: ["Electrical", "Plumbing"],
            areas: nil,
            phases: nil
        )

        // When & Then
        XCTAssertTrue(scope.isInScope(itemId: "Electrical", type: .trade))
        XCTAssertFalse(scope.isInScope(itemId: "HVAC", type: .trade))
    }
}

// MARK: - ProjectRole Tests

final class ProjectRoleTests: XCTestCase {
    func testRequiresScope_ForSpecificRoles() {
        XCTAssertTrue(ProjectRole.foreman.requiresScope)
        XCTAssertTrue(ProjectRole.subcontractor.requiresScope)

        XCTAssertFalse(ProjectRole.projectAdmin.requiresScope)
        XCTAssertFalse(ProjectRole.projectManager.requiresScope)
    }

    func testDisplayName_ReturnsFormattedName() {
        XCTAssertEqual(ProjectRole.projectAdmin.displayName, "Project Admin")
        XCTAssertEqual(ProjectRole.projectManager.displayName, "Project Manager")
        XCTAssertEqual(ProjectRole.ownerRep.displayName, "Owner's Rep")
    }
}
