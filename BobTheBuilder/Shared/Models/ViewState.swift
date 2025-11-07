//
//  ViewState.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import Foundation

/// Generic view state enum for consistent state management across all views
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(Error)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var data: T? {
        if case .loaded(let data) = self { return data }
        return nil
    }

    var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }

    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }

    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }
}
