//
//  AuthModels.swift
//  BobTheBuilder
//
//  Created on November 9, 2025.
//

import Foundation

// MARK: - Login Request

struct LoginRequest: Codable {
    let email: String
    let password: String
}

// MARK: - Login Response

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    let user: User
}

// MARK: - User Model

struct User: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String?
    let avatar: String?
    let roles: [String]
    let organizations: [UserOrganization]?
    let createdAt: String?
    let updatedAt: String?

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var initials: String {
        let firstInitial = firstName.prefix(1)
        let lastInitial = lastName.prefix(1)
        return "\(firstInitial)\(lastInitial)".uppercased()
    }

    var primaryRole: String? {
        return roles.first
    }

    var formattedRoles: String {
        return roles.map { formatRole($0) }.joined(separator: ", ")
    }

    private func formatRole(_ role: String) -> String {
        return role
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    // Backend uses camelCase, so no CodingKeys needed for most fields
}

// MARK: - User Organization

struct UserOrganization: Codable {
    let id: String
    let name: String
    let type: String
    let role: String
    let isActive: Bool

    var formattedType: String {
        return type
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}

// MARK: - Auth Tokens

struct AuthTokens: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

// MARK: - Registration Request

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let phoneNumber: String?

    // Backend uses camelCase, so no CodingKeys needed
}

// MARK: - API Error Response

struct APIErrorResponse: Codable {
    let message: String
    let statusCode: Int?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case message
        case statusCode = "status_code"
        case error
    }
}
