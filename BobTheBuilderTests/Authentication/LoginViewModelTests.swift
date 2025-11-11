//
//  LoginViewModelTests.swift
//  BobTheBuilderTests
//
//  Created on November 9, 2025.
//

import XCTest
import Combine
@testable import BobTheBuilder

@MainActor
class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = LoginViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Email Validation Tests

    func testEmailValidation_WithInvalidEmail_ShowsError() async {
        // Given
        let expectation = expectation(description: "Email validation")

        // When
        viewModel.email = "invalid-email"

        // Wait for debounce
        try? await Task.sleep(nanoseconds: 600_000_000) // 600ms

        // Then
        await MainActor.run {
            XCTAssertNotNil(viewModel.emailError, "Email error should be present for invalid email")
            XCTAssertEqual(viewModel.emailError, "Please enter a valid email address")
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testEmailValidation_WithValidEmail_NoError() async {
        // Given
        let expectation = expectation(description: "Valid email")

        // When
        viewModel.email = "test@example.com"

        // Wait for debounce
        try? await Task.sleep(nanoseconds: 600_000_000) // 600ms

        // Then
        await MainActor.run {
            XCTAssertNil(viewModel.emailError, "Email error should be nil for valid email")
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testEmailValidation_WithEmptyEmail_NoError() async {
        // Given
        let expectation = expectation(description: "Empty email")

        // When
        viewModel.email = ""

        // Wait for debounce
        try? await Task.sleep(nanoseconds: 600_000_000) // 600ms

        // Then
        await MainActor.run {
            XCTAssertNil(viewModel.emailError, "Email error should be nil for empty email")
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    // MARK: - Password Validation Tests

    func testPasswordValidation_WithShortPassword_ShowsError() async {
        // Given
        let expectation = expectation(description: "Short password")

        // When
        viewModel.password = "123"

        // Wait for debounce
        try? await Task.sleep(nanoseconds: 600_000_000) // 600ms

        // Then
        await MainActor.run {
            XCTAssertNotNil(viewModel.passwordError, "Password error should be present for short password")
            XCTAssertEqual(viewModel.passwordError, "Password must be at least 6 characters")
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testPasswordValidation_WithValidPassword_NoError() async {
        // Given
        let expectation = expectation(description: "Valid password")

        // When
        viewModel.password = "password123"

        // Wait for debounce
        try? await Task.sleep(nanoseconds: 600_000_000) // 600ms

        // Then
        await MainActor.run {
            XCTAssertNil(viewModel.passwordError, "Password error should be nil for valid password")
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testPasswordValidation_WithEmptyPassword_NoError() async {
        // Given
        let expectation = expectation(description: "Empty password")

        // When
        viewModel.password = ""

        // Wait for debounce
        try? await Task.sleep(nanoseconds: 600_000_000) // 600ms

        // Then
        await MainActor.run {
            XCTAssertNil(viewModel.passwordError, "Password error should be nil for empty password")
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    // MARK: - Login Button State Tests

    func testCanLogin_WithEmptyFields_ReturnsFalse() {
        // Given
        viewModel.email = ""
        viewModel.password = ""

        // Then
        XCTAssertFalse(viewModel.canLogin, "canLogin should be false with empty fields")
    }

    func testCanLogin_WithValidCredentials_ReturnsTrue() async {
        // Given
        let expectation = expectation(description: "Can login with valid credentials")

        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        // Wait for debounce and validation
        try? await Task.sleep(nanoseconds: 600_000_000) // 600ms

        // Then
        await MainActor.run {
            XCTAssertTrue(viewModel.canLogin, "canLogin should be true with valid credentials")
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testCanLogin_WithEmailError_ReturnsFalse() async {
        // Given
        let expectation = expectation(description: "Can't login with email error")

        viewModel.email = "invalid"
        viewModel.password = "password123"

        // Wait for debounce and validation
        try? await Task.sleep(nanoseconds: 600_000_000) // 600ms

        // Then
        await MainActor.run {
            XCTAssertFalse(viewModel.canLogin, "canLogin should be false with invalid email")
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testCanLogin_WithPasswordError_ReturnsFalse() async {
        // Given
        let expectation = expectation(description: "Can't login with password error")

        viewModel.email = "test@example.com"
        viewModel.password = "123"

        // Wait for debounce and validation
        try? await Task.sleep(nanoseconds: 600_000_000) // 600ms

        // Then
        await MainActor.run {
            XCTAssertFalse(viewModel.canLogin, "canLogin should be false with short password")
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testCanLogin_WhileLoading_ReturnsFalse() {
        // Given
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.viewState = .loading

        // Then
        XCTAssertFalse(viewModel.canLogin, "canLogin should be false while loading")
    }

    // MARK: - Password Visibility Tests

    func testPasswordVisibility_Toggle() {
        // Given
        XCTAssertFalse(viewModel.isPasswordVisible, "Password should be hidden initially")

        // When
        viewModel.isPasswordVisible.toggle()

        // Then
        XCTAssertTrue(viewModel.isPasswordVisible, "Password should be visible after toggle")

        // When
        viewModel.isPasswordVisible.toggle()

        // Then
        XCTAssertFalse(viewModel.isPasswordVisible, "Password should be hidden after second toggle")
    }

    // MARK: - View State Tests

    func testInitialState_IsIdle() {
        // Then
        XCTAssertTrue(viewModel.viewState.isIdle, "Initial view state should be idle")
        XCTAssertFalse(viewModel.viewState.isLoading, "Initial view state should not be loading")
    }

    func testErrorState_ShowsError() {
        // Given
        viewModel.errorMessage = "Test error message"
        viewModel.showError = true

        // Then
        XCTAssertTrue(viewModel.showError, "showError should be true")
        XCTAssertEqual(viewModel.errorMessage, "Test error message")
    }

    // MARK: - Login Flow Tests

    func testLogin_WithEmptyCredentials_DoesNotProceed() {
        // Given
        viewModel.email = ""
        viewModel.password = ""

        // When
        viewModel.login()

        // Then
        XCTAssertTrue(viewModel.viewState.isIdle, "View state should remain idle")
    }

    // Note: Testing actual API calls would require mocking the APIClient
    // or using dependency injection. For now, we're testing the validation logic.
}
