//
//  ViewStateTests.swift
//  BobTheBuilderTests
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import XCTest
@testable import Bob_Dev

class ViewStateTests: XCTestCase {

    // MARK: - ViewState Properties Tests

    func testIdleState() {
        let state: ViewState<String> = .idle

        XCTAssertTrue(state.isIdle)
        XCTAssertFalse(state.isLoading)
        XCTAssertFalse(state.isEmpty)
        XCTAssertNil(state.data)
        XCTAssertNil(state.error)
    }

    func testLoadingState() {
        let state: ViewState<String> = .loading

        XCTAssertTrue(state.isLoading)
        XCTAssertFalse(state.isIdle)
        XCTAssertFalse(state.isEmpty)
        XCTAssertNil(state.data)
        XCTAssertNil(state.error)
    }

    func testLoadedState() {
        let testData = "Test Data"
        let state: ViewState<String> = .loaded(testData)

        XCTAssertFalse(state.isLoading)
        XCTAssertFalse(state.isIdle)
        XCTAssertFalse(state.isEmpty)
        XCTAssertEqual(state.data, testData)
        XCTAssertNil(state.error)
    }

    func testEmptyState() {
        let state: ViewState<[String]> = .empty

        XCTAssertTrue(state.isEmpty)
        XCTAssertFalse(state.isLoading)
        XCTAssertFalse(state.isIdle)
        XCTAssertNil(state.data)
        XCTAssertNil(state.error)
    }

    func testErrorState() {
        let testError = NSError(domain: "TestError", code: 500, userInfo: nil)
        let state: ViewState<String> = .error(testError)

        XCTAssertFalse(state.isLoading)
        XCTAssertFalse(state.isIdle)
        XCTAssertFalse(state.isEmpty)
        XCTAssertNil(state.data)
        XCTAssertNotNil(state.error)
        XCTAssertEqual((state.error as NSError?)?.code, 500)
    }

    func testLoadedStateWithArray() {
        let testArray = ["item1", "item2", "item3"]
        let state: ViewState<[String]> = .loaded(testArray)

        XCTAssertEqual(state.data?.count, 3)
        XCTAssertEqual(state.data?.first, "item1")
    }

    func testLoadedStateWithComplexType() {
        struct TestModel {
            let id: String
            let name: String
        }

        let testModel = TestModel(id: "1", name: "Test")
        let state: ViewState<TestModel> = .loaded(testModel)

        XCTAssertEqual(state.data?.id, "1")
        XCTAssertEqual(state.data?.name, "Test")
    }
}
