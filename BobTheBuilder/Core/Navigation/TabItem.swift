//
//  TabItem.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

enum TabItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case projects = "Projects"
    case rfis = "RFIs"
    case settings = "Settings"

    var systemImage: String {
        switch self {
        case .dashboard: return "house.fill"
        case .projects: return "hammer.fill"
        case .rfis: return "doc.text.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var selectedSystemImage: String {
        switch self {
        case .dashboard: return "house.fill"
        case .projects: return "hammer.fill"
        case .rfis: return "doc.text.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var title: String {
        self.rawValue
    }

    var badge: Int? {
        // Placeholder for future badge counts
        switch self {
        case .rfis: return nil // Will show unread RFI count
        default: return nil
        }
    }
}
