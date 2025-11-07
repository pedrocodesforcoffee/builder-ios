//
//  APIClientProtocol.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import Foundation
import Combine

protocol APIClientProtocol {
    func execute<T: APIRequest>(_ request: T) async throws -> T.Response
    func execute<T: APIRequest>(_ request: T) -> AnyPublisher<T.Response, APIError>
}
