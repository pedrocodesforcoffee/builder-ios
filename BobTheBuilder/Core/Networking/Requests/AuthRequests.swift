//
//  AuthRequests.swift
//  BobTheBuilder
//
//  Created on November 9, 2025.
//

import Foundation

// MARK: - Login Request

struct LoginAPIRequest: APIRequest {
    typealias Response = LoginResponse

    let email: String
    let password: String

    var path: String { "/auth/login" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
    var body: Data? {
        try? JSONEncoder().encode(LoginRequest(email: email, password: password))
    }
}

// MARK: - Refresh Token Request

struct RefreshTokenAPIRequest: APIRequest {
    typealias Response = RefreshTokenResponse

    let refreshToken: String

    var path: String { "/auth/refresh" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
    var body: Data? {
        try? JSONEncoder().encode(["refreshToken": refreshToken])
    }
}

// MARK: - Refresh Token Response

struct RefreshTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
}

// MARK: - Register Request

struct RegisterAPIRequest: APIRequest {
    typealias Response = LoginResponse // Same response as login

    let email: String
    let password: String
    let firstName: String
    let lastName: String

    var path: String { "/auth/register" }
    var method: HTTPMethod { .post }
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
    var body: Data? {
        try? JSONEncoder().encode(RegisterRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: nil
        ))
    }
}

// MARK: - Logout Request

struct LogoutAPIRequest: APIRequest {
    typealias Response = EmptyResponse

    var path: String { "/auth/logout" }
    var method: HTTPMethod { .post }
    var body: Data? { nil }
}

// MARK: - Empty Response

struct EmptyResponse: Codable {}
