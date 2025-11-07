//
//  APIError.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case httpError(statusCode: Int, data: Data?)
    case timeout
    case noInternetConnection
    case unauthorized
    case serverError(message: String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let statusCode, _):
            return "HTTP error with status code: \(statusCode)"
        case .timeout:
            return "Request timed out"
        case .noInternetConnection:
            return "No internet connection"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown:
            return "An unknown error occurred"
        }
    }

    var isRetriable: Bool {
        switch self {
        case .timeout, .networkError, .noInternetConnection:
            return true
        case .httpError(let statusCode, _):
            return statusCode >= 500
        default:
            return false
        }
    }

    // MARK: - Equatable

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.timeout, .timeout),
             (.noInternetConnection, .noInternetConnection),
             (.unauthorized, .unauthorized),
             (.unknown, .unknown):
            return true
        case (.decodingError(let lhsError), .decodingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.httpError(let lhsCode, _), .httpError(let rhsCode, _)):
            return lhsCode == rhsCode
        case (.serverError(let lhsMessage), .serverError(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
