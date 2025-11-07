//
//  NetworkLogger.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import Foundation
import OSLog

final class NetworkLogger {
    static let shared = NetworkLogger()
    let logger = Logger(subsystem: "com.bobthebuilder.app", category: "Network")
    private let dateFormatter: DateFormatter

    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
    }

    func logRequest(_ request: URLRequest) {
        let timestamp = dateFormatter.string(from: Date())
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "Invalid URL"

        logger.debug("[\(timestamp)] 🚀 \(method) \(url)")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logger.debug("📋 Headers: \(String(describing: headers))")
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            logger.debug("📦 Body: \(bodyString)")
        }
    }

    func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        let timestamp = dateFormatter.string(from: Date())

        if let error = error {
            logger.error("[\(timestamp)] ❌ Error: \(error.localizedDescription)")
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("[\(timestamp)] ❌ Invalid response")
            return
        }

        let statusCode = httpResponse.statusCode
        let url = httpResponse.url?.absoluteString ?? "Unknown URL"
        let emoji = statusEmoji(for: statusCode)

        logger.debug("[\(timestamp)] \(emoji) \(statusCode) \(url)")

        if let data = data {
            logger.debug("📦 Response size: \(data.count) bytes")

            if let responseString = String(data: data, encoding: .utf8),
               responseString.count < 1000 {
                logger.debug("📄 Response: \(responseString)")
            }
        }
    }

    private func statusEmoji(for statusCode: Int) -> String {
        switch statusCode {
        case 200...299: return "✅"
        case 300...399: return "↩️"
        case 400...499: return "⚠️"
        case 500...599: return "🔥"
        default: return "❓"
        }
    }
}
