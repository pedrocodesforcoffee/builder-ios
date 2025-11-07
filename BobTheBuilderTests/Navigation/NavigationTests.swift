//
//  NavigationTests.swift
//  BobTheBuilderTests
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import XCTest
import SwiftUI
@testable import BobTheBuilder

@MainActor
final class NavigationTests: XCTestCase {

    var navigationManager: NavigationPathManager!

    override func setUp() async throws {
        try await super.setUp()
        // Create a fresh instance for each test
        navigationManager = NavigationPathManager()
    }

    override func tearDown() async throws {
        navigationManager = nil
        try await super.tearDown()
    }

    // MARK: - NavigationPathManager Tests

    func testNavigationPathManagerInitialState() {
        XCTAssertTrue(navigationManager.projectsPath.isEmpty)
        XCTAssertTrue(navigationManager.rfisPath.isEmpty)
        XCTAssertTrue(navigationManager.settingsPath.isEmpty)
        XCTAssertEqual(navigationManager.selectedTab, .projects)
    }

    func testNavigateToProjectDetail() {
        let destination = NavigationDestination.projectDetail(projectId: "123")
        navigationManager.navigate(to: destination, in: .projects)

        XCTAssertEqual(navigationManager.selectedTab, .projects)
        XCTAssertEqual(navigationManager.projectsPath.count, 1)
    }

    func testNavigateToRFIDetail() {
        let destination = NavigationDestination.rfiDetail(rfiId: "456")
        navigationManager.navigate(to: destination, in: .rfis)

        XCTAssertEqual(navigationManager.selectedTab, .rfis)
        XCTAssertEqual(navigationManager.rfisPath.count, 1)
    }

    func testNavigateMultipleDestinations() {
        navigationManager.navigate(to: .projectDetail(projectId: "1"), in: .projects)
        navigationManager.navigate(to: .createRFI(projectId: "1"))
        navigationManager.navigate(to: .rfiDetail(rfiId: "2"))

        XCTAssertEqual(navigationManager.projectsPath.count, 3)
    }

    func testPopToRoot() {
        navigationManager.navigate(to: .projectDetail(projectId: "1"), in: .projects)
        navigationManager.navigate(to: .createRFI(projectId: "1"))
        navigationManager.navigate(to: .rfiDetail(rfiId: "2"))

        XCTAssertEqual(navigationManager.projectsPath.count, 3)

        navigationManager.popToRoot(in: .projects)

        XCTAssertTrue(navigationManager.projectsPath.isEmpty)
    }

    func testPop() {
        navigationManager.navigate(to: .projectDetail(projectId: "1"), in: .projects)
        navigationManager.navigate(to: .createRFI(projectId: "1"))

        XCTAssertEqual(navigationManager.projectsPath.count, 2)

        navigationManager.pop(in: .projects)

        XCTAssertEqual(navigationManager.projectsPath.count, 1)
    }

    func testPopEmptyPath() {
        XCTAssertTrue(navigationManager.projectsPath.isEmpty)

        navigationManager.pop(in: .projects)

        // Should not crash and path should remain empty
        XCTAssertTrue(navigationManager.projectsPath.isEmpty)
    }

    func testReset() {
        navigationManager.navigate(to: .projectDetail(projectId: "1"), in: .projects)
        navigationManager.navigate(to: .rfiDetail(rfiId: "2"), in: .rfis)
        navigationManager.navigate(to: .settings, in: .settings)

        navigationManager.reset()

        XCTAssertTrue(navigationManager.projectsPath.isEmpty)
        XCTAssertTrue(navigationManager.rfisPath.isEmpty)
        XCTAssertTrue(navigationManager.settingsPath.isEmpty)
        XCTAssertEqual(navigationManager.selectedTab, .projects)
    }

    // MARK: - AppCoordinator Tests

    func testAppCoordinatorInitialState() async {
        let coordinator = AppCoordinator()

        // Initially should be loading
        XCTAssertTrue(coordinator.isLoading)
        XCTAssertFalse(coordinator.isAuthenticated)
        XCTAssertFalse(coordinator.showOnboarding)
        XCTAssertNil(coordinator.appError)
    }

    func testCompleteOnboarding() {
        let coordinator = AppCoordinator()
        UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")

        coordinator.showOnboarding = true
        coordinator.completeOnboarding()

        XCTAssertFalse(coordinator.showOnboarding)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
    }

    func testLogin() {
        let coordinator = AppCoordinator()
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")

        coordinator.login()

        XCTAssertTrue(coordinator.isAuthenticated)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "isAuthenticated"))

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
    }

    func testLogout() {
        let coordinator = AppCoordinator()
        UserDefaults.standard.set(true, forKey: "isAuthenticated")

        coordinator.isAuthenticated = true
        coordinator.logout()

        XCTAssertFalse(coordinator.isAuthenticated)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "isAuthenticated"))

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
    }

    func testDeepLinkHandling() {
        let coordinator = AppCoordinator()
        let url = URL(string: "bobthebuilder://project/123")!

        coordinator.handleDeepLink(url)

        let navigationManager = NavigationPathManager.shared
        XCTAssertEqual(navigationManager.selectedTab, .projects)
        // Note: We can't easily test the path content due to NavigationPath being opaque
    }

    // MARK: - NavigationDestination Tests

    func testNavigationDestinationID() {
        let projectDetail = NavigationDestination.projectDetail(projectId: "123")
        XCTAssertEqual(projectDetail.id, "project_123")

        let rfiDetail = NavigationDestination.rfiDetail(rfiId: "456")
        XCTAssertEqual(rfiDetail.id, "rfi_456")

        let createProject = NavigationDestination.createProject
        XCTAssertEqual(createProject.id, "create_project")

        let createRFI = NavigationDestination.createRFI(projectId: "789")
        XCTAssertEqual(createRFI.id, "create_rfi_789")
    }

    func testNavigationDestinationEquality() {
        let dest1 = NavigationDestination.projectDetail(projectId: "123")
        let dest2 = NavigationDestination.projectDetail(projectId: "123")
        let dest3 = NavigationDestination.projectDetail(projectId: "456")

        XCTAssertEqual(dest1, dest2)
        XCTAssertNotEqual(dest1, dest3)
    }

    // MARK: - TabItem Tests

    func testTabItemProperties() {
        XCTAssertEqual(TabItem.projects.title, "Projects")
        XCTAssertEqual(TabItem.projects.systemImage, "hammer.fill")

        XCTAssertEqual(TabItem.rfis.title, "RFIs")
        XCTAssertEqual(TabItem.rfis.systemImage, "doc.text.fill")

        XCTAssertEqual(TabItem.settings.title, "Settings")
        XCTAssertEqual(TabItem.settings.systemImage, "gearshape.fill")
    }

    func testTabItemAllCases() {
        let allCases = TabItem.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.projects))
        XCTAssertTrue(allCases.contains(.rfis))
        XCTAssertTrue(allCases.contains(.settings))
    }
}
