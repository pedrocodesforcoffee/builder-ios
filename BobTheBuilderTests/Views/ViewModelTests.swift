//
//  ViewModelTests.swift
//  BobTheBuilderTests
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import XCTest
import Combine
@testable import Bob_Dev

class LoginViewModelTests: XCTestCase {

    var viewModel: LoginViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = LoginViewModel()
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertTrue(viewModel.viewState.isIdle)
        XCTAssertFalse(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "")
        XCTAssertFalse(viewModel.canLogin)
    }

    // MARK: - Form Validation Tests

    func testCanLoginWithEmptyFields() {
        viewModel.email = ""
        viewModel.password = ""
        XCTAssertFalse(viewModel.canLogin)
    }

    func testCanLoginWithOnlyEmail() {
        viewModel.email = "test@example.com"
        viewModel.password = ""
        XCTAssertFalse(viewModel.canLogin)
    }

    func testCanLoginWithOnlyPassword() {
        viewModel.email = ""
        viewModel.password = "password123"
        XCTAssertFalse(viewModel.canLogin)
    }

    func testCanLoginWithBothFields() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        XCTAssertTrue(viewModel.canLogin)
    }

    // MARK: - Login Flow Tests

    func testLoginSetsLoadingState() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        let expectation = XCTestExpectation(description: "Loading state is set")

        viewModel.$viewState
            .dropFirst() // Skip initial idle state
            .sink { state in
                if state.isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login()

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoginWithEmptyFieldsDoesNothing() {
        viewModel.email = ""
        viewModel.password = ""

        viewModel.login()

        XCTAssertTrue(viewModel.viewState.isIdle)
    }

    func testLoginEventuallyShowsError() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        let expectation = XCTestExpectation(description: "Error is shown")

        viewModel.$showError
            .dropFirst() // Skip initial false
            .sink { showError in
                if showError {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login()

        wait(for: [expectation], timeout: 3.0)
        XCTAssertTrue(viewModel.showError)
        XCTAssertFalse(viewModel.errorMessage.isEmpty)
    }
}

class ProjectListViewModelTests: XCTestCase {

    var viewModel: ProjectListViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = ProjectListViewModel()
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertTrue(viewModel.viewState.isIdle)
    }

    // MARK: - Load Projects Tests

    func testLoadProjectsSetsLoadingState() {
        let expectation = XCTestExpectation(description: "Loading state is set")

        viewModel.$viewState
            .dropFirst() // Skip initial idle state
            .sink { state in
                if state.isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadProjects()

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadProjectsEventuallyLoadsData() {
        let expectation = XCTestExpectation(description: "Projects are loaded")

        viewModel.$viewState
            .sink { state in
                if let projects = state.data {
                    XCTAssertFalse(projects.isEmpty)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadProjects()

        wait(for: [expectation], timeout: 2.0)
    }

    func testLoadProjectsOnlyLoadsOnce() {
        viewModel.loadProjects()
        let firstState = viewModel.viewState

        // Try to load again while loading
        viewModel.loadProjects()

        // State should not change because guard prevents reload
        XCTAssertTrue(viewModel.viewState.isLoading)
    }

    func testRefreshProjectsUpdatesData() async {
        // First load
        viewModel.loadProjects()

        // Wait for initial load
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        // Now refresh
        await viewModel.refreshProjects()

        // Verify data is loaded
        XCTAssertNotNil(viewModel.viewState.data)
        XCTAssertFalse(viewModel.viewState.data?.isEmpty ?? true)
    }
}

class RFIListViewModelTests: XCTestCase {

    var viewModel: RFIListViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = RFIListViewModel()
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertTrue(viewModel.viewState.isIdle)
    }

    // MARK: - Load RFIs Tests

    func testLoadRFIsSetsLoadingState() {
        let expectation = XCTestExpectation(description: "Loading state is set")

        viewModel.$viewState
            .dropFirst() // Skip initial idle state
            .sink { state in
                if state.isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadRFIs()

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadRFIsEventuallyLoadsData() {
        let expectation = XCTestExpectation(description: "RFIs are loaded")

        viewModel.$viewState
            .sink { state in
                if let rfis = state.data {
                    XCTAssertFalse(rfis.isEmpty)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadRFIs()

        wait(for: [expectation], timeout: 2.0)
    }

    func testLoadRFIsOnlyLoadsOnce() {
        viewModel.loadRFIs()
        let firstState = viewModel.viewState

        // Try to load again while loading
        viewModel.loadRFIs()

        // State should not change because guard prevents reload
        XCTAssertTrue(viewModel.viewState.isLoading)
    }

    func testRefreshRFIsUpdatesData() async {
        // First load
        viewModel.loadRFIs()

        // Wait for initial load
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        // Now refresh
        await viewModel.refreshRFIs()

        // Verify data is loaded
        XCTAssertNotNil(viewModel.viewState.data)
        XCTAssertFalse(viewModel.viewState.data?.isEmpty ?? true)
    }

    func testLoadedRFIsContainDifferentStatuses() {
        let expectation = XCTestExpectation(description: "RFIs are loaded with different statuses")

        viewModel.$viewState
            .sink { state in
                if let rfis = state.data {
                    let statuses = Set(rfis.map { $0.status })
                    XCTAssertTrue(statuses.count > 1)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadRFIs()

        wait(for: [expectation], timeout: 2.0)
    }

    func testLoadedRFIsContainDifferentPriorities() {
        let expectation = XCTestExpectation(description: "RFIs are loaded with different priorities")

        viewModel.$viewState
            .sink { state in
                if let rfis = state.data {
                    let priorities = Set(rfis.map { $0.priority })
                    XCTAssertTrue(priorities.count > 1)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadRFIs()

        wait(for: [expectation], timeout: 2.0)
    }
}
