//
//  ConfigurationTests.swift
//  BobTheBuilderTests
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import XCTest
@testable import Bob_Dev

class ConfigurationTests: XCTestCase {

    func testConfigurationLoads() {
        let config = AppConfiguration.shared

        XCTAssertFalse(config.apiBaseURL.isEmpty, "API Base URL should not be empty")
        XCTAssertFalse(config.appVersion.isEmpty, "App version should not be empty")
        XCTAssertFalse(config.buildNumber.isEmpty, "Build number should not be empty")
        XCTAssertFalse(config.appName.isEmpty, "App name should not be empty")
    }

    func testEnvironmentIsValid() {
        let config = AppConfiguration.shared
        let validEnvironments: [Environment] = [.development, .staging, .production]

        XCTAssertTrue(validEnvironments.contains(config.environment), "Environment should be one of the valid options")
    }

    func testAPIBaseURLFormat() {
        let config = AppConfiguration.shared

        XCTAssertTrue(config.apiBaseURL.starts(with: "https://") || config.apiBaseURL.starts(with: "http://"),
                     "API Base URL should start with http:// or https://")
    }

    func testEnvironmentDisplayName() {
        XCTAssertEqual(Environment.development.displayName, "DEV")
        XCTAssertEqual(Environment.staging.displayName, "STAGE")
        XCTAssertEqual(Environment.production.displayName, "PROD")
    }

    func testEnvironmentRawValues() {
        XCTAssertEqual(Environment.development.rawValue, "Development")
        XCTAssertEqual(Environment.staging.rawValue, "Staging")
        XCTAssertEqual(Environment.production.rawValue, "Production")
    }
}
