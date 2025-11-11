//
//  APIClient.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import Foundation
import Combine

final class APIClient: APIClientProtocol {
    static let shared = APIClient()

    private let session: URLSession
    private let baseURL: String
    private let logger = NetworkLogger.shared
    private var retryDelayBase: TimeInterval = 1.0

    init(session: URLSession = .shared, baseURL: String? = nil) {
        self.session = session
        self.baseURL = baseURL ?? AppConfiguration.shared.apiBaseURL
    }

    func execute<T: APIRequest>(_ request: T) async throws -> T.Response {
        var urlRequest = try buildURLRequest(from: request)

        var lastError: Error?
        var retryCount = 0
        var shouldRetryWith401 = true

        while retryCount <= request.maxRetries {
            if retryCount > 0 {
                let delay = retryDelayBase * pow(2.0, Double(retryCount - 1))
                logger.logger.debug("🔄 Retrying request (attempt \(retryCount + 1)/\(request.maxRetries + 1)) after \(delay)s")
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }

            do {
                logger.logRequest(urlRequest)

                let (data, response) = try await session.data(for: urlRequest)

                logger.logResponse(response, data: data, error: nil)

                // Check for 401 Unauthorized
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 401,
                   shouldRetryWith401 {

                    print("⚠️ Received 401, triggering token refresh")

                    // Post notification for auth manager to handle
                    NotificationCenter.default.post(name: .unauthorizedResponse, object: nil)

                    // Wait a bit for token refresh
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

                    // Only retry 401 once per request
                    shouldRetryWith401 = false

                    // Rebuild request with new token
                    urlRequest = try buildURLRequest(from: request)

                    // Retry with new token
                    let (retryData, retryResponse) = try await session.data(for: urlRequest)

                    logger.logResponse(retryResponse, data: retryData, error: nil)

                    try validateResponse(retryResponse, data: retryData)

                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .iso8601

                    return try decoder.decode(T.Response.self, from: retryData)
                }

                try validateResponse(response, data: data)

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601

                return try decoder.decode(T.Response.self, from: data)

            } catch {
                lastError = error

                let apiError = mapToAPIError(error)
                if !apiError.isRetriable || retryCount >= request.maxRetries {
                    throw apiError
                }

                retryCount += 1
            }
        }

        throw mapToAPIError(lastError ?? APIError.unknown)
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

    private func buildURLRequest<T: APIRequest>(from request: T) throws -> URLRequest {
        guard let url = URL(string: baseURL + request.path) else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeout

        // Default headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("iOS/\(AppConfiguration.shared.appVersion)", forHTTPHeaderField: "User-Agent")

        // Add authentication token if available
        if let token = TokenManager.shared.getAccessToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Custom headers
        request.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // Query parameters
        if let parameters = request.parameters,
           var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            urlRequest.url = components.url
        }

        // Body
        if let body = request.body {
            urlRequest.httpBody = body
        }

        return urlRequest
    }

    private func validateResponse(_ response: URLResponse?, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        switch httpResponse.statusCode {
        case 200...299:
            guard let data = data, !data.isEmpty else {
                throw APIError.noData
            }
        case 401:
            throw APIError.unauthorized
        case 400...499:
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        case 500...599:
            let message = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Server error"
            throw APIError.serverError(message: message)
        default:
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
    }

    private func mapToAPIError(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }

        let nsError = error as NSError

        switch nsError.code {
        case NSURLErrorTimedOut:
            return .timeout
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            return .noInternetConnection
        case NSURLErrorCannotDecodeRawData, NSURLErrorCannotDecodeContentData:
            return .decodingError(error)
        default:
            return .networkError(error)
        }
    }
}
