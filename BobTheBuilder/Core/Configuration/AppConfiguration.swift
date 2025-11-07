//
//  AppConfiguration.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import Foundation
import SwiftUI

enum Environment: String {
    case development = "Development"
    case staging = "Staging"
    case production = "Production"

    var displayName: String {
        switch self {
        case .development: return "DEV"
        case .staging: return "STAGE"
        case .production: return "PROD"
        }
    }

    var themeColor: Color {
        switch self {
        case .development: return .orange
        case .staging: return .blue
        case .production: return .green
        }
    }
}

struct AppConfiguration {
    static let shared = AppConfiguration()

    private init() {}

    var apiBaseURL: String {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String else {
            fatalError("API_BASE_URL not found in Info.plist")
        }
        return urlString
    }

    var environment: Environment {
        guard let environmentString = Bundle.main.object(forInfoDictionaryKey: "ENVIRONMENT") as? String,
              let environment = Environment(rawValue: environmentString) else {
            fatalError("ENVIRONMENT not found or invalid in Info.plist")
        }
        return environment
    }

    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }

    var isDebugBuild: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Bob the Builder"
    }
}
