//
//  HealthCheckRequest.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import Foundation

struct HealthCheckRequest: APIRequest {
    typealias Response = HealthCheckResponse

    var path: String { "/health" }
    var method: HTTPMethod { .get }
}

struct HealthCheckResponse: Codable, Equatable {
    let status: String
    let version: String
    let timestamp: Date?
}
