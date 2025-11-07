//
//  APIClientTests.swift
//  BobTheBuilderTests
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import XCTest
@testable import BobTheBuilder

class APIClientTests: XCTestCase {
    var mockClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        mockClient = MockAPIClient()
        mockClient.requestDelay = 0.1
    }

    override func tearDown() {
        mockClient.reset()
        super.tearDown()
    }

    func testSuccessfulRequest() async throws {
        // Arrange
        let expectedResponse = HealthCheckResponse(
            status: "healthy",
            version: "1.0.0",
            timestamp: Date()
        )
        mockClient.setMockResponse(expectedResponse, for: .get, path: "/health")

        // Act
        let request = HealthCheckRequest()
        let response = try await mockClient.execute(request)

        // Assert
        XCTAssertEqual(response.status, "healthy")
        XCTAssertEqual(response.version, "1.0.0")
        XCTAssertEqual(mockClient.requestLog.count, 1)
        XCTAssertEqual(mockClient.requestLog.first, "GET /health")
    }

    func testNetworkError() async {
        // Arrange
        mockClient.setMockError(.noInternetConnection, for: .get, path: "/health")

        // Act & Assert
        let request = HealthCheckRequest()

        do {
            _ = try await mockClient.execute(request)
            XCTFail("Expected error but got success")
        } catch let error as APIError {
            XCTAssertEqual(error, .noInternetConnection)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testRequestLogging() async throws {
        // Arrange
        let response = HealthCheckResponse(status: "ok", version: "1.0", timestamp: nil)
        mockClient.setMockResponse(response, for: .get, path: "/health")

        // Act
        let request = HealthCheckRequest()
        _ = try await mockClient.execute(request)
        _ = try await mockClient.execute(request)

        // Assert
        XCTAssertEqual(mockClient.requestLog.count, 2)
        XCTAssertTrue(mockClient.requestLog.allSatisfy { $0 == "GET /health" })
    }

    func testUnauthorizedError() async {
        // Arrange
        mockClient.setMockError(.unauthorized, for: .get, path: "/health")

        // Act & Assert
        let request = HealthCheckRequest()

        do {
            _ = try await mockClient.execute(request)
            XCTFail("Expected unauthorized error")
        } catch let error as APIError {
            XCTAssertEqual(error, .unauthorized)
            XCTAssertFalse(error.isRetriable)
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testRetriableError() {
        // Test that timeout is retriable
        let timeoutError = APIError.timeout
        XCTAssertTrue(timeoutError.isRetriable)

        // Test that unauthorized is not retriable
        let unauthorizedError = APIError.unauthorized
        XCTAssertFalse(unauthorizedError.isRetriable)

        // Test that 500 error is retriable
        let serverError = APIError.httpError(statusCode: 500, data: nil)
        XCTAssertTrue(serverError.isRetriable)

        // Test that 404 error is not retriable
        let notFoundError = APIError.httpError(statusCode: 404, data: nil)
        XCTAssertFalse(notFoundError.isRetriable)
    }
}
