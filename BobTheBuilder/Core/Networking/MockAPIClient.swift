//
//  MockAPIClient.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import Foundation
import Combine

final class MockAPIClient: APIClientProtocol {
    var mockResponses: [String: Any] = [:]
    var mockErrors: [String: APIError] = [:]
    var requestDelay: TimeInterval = 0.5
    var requestLog: [String] = []

    func execute<T: APIRequest>(_ request: T) async throws -> T.Response {
        let key = "\(request.method.rawValue) \(request.path)"
        requestLog.append(key)

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(requestDelay * 1_000_000_000))

        // Check for mock error
        if let error = mockErrors[key] {
            throw error
        }

        // Check for mock response
        if let response = mockResponses[key] as? T.Response {
            return response
        }

        // Try to decode from mock JSON data
        if let jsonData = mockResponses[key] as? Data {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.Response.self, from: jsonData)
        }

        throw APIError.noData
    }

    func execute<T: APIRequest>(_ request: T) -> AnyPublisher<T.Response, APIError> {
        Future { promise in
            Task {
                do {
                    let response = try await self.execute(request)
                    promise(.success(response))
                } catch let error as APIError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(.unknown))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func setMockResponse<T: Encodable>(_ response: T, for method: HTTPMethod, path: String) {
        let key = "\(method.rawValue) \(path)"
        mockResponses[key] = response
    }

    func setMockError(_ error: APIError, for method: HTTPMethod, path: String) {
        let key = "\(method.rawValue) \(path)"
        mockErrors[key] = error
    }

    func reset() {
        mockResponses.removeAll()
        mockErrors.removeAll()
        requestLog.removeAll()
    }
}
