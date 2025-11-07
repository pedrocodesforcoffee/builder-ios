//
//  NavigationCompatibility.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

// MARK: - iOS 15 Compatibility

/// Compatibility wrapper for NavigationStack (iOS 16+) and NavigationView (iOS 15)
struct CompatibleNavigationStack<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationView {
            content
        }
        .navigationViewStyle(.stack)
    }
}

// iOS 16+ NavigationStack support - currently disabled for iOS 15 compatibility
// Uncomment when minimum deployment target is iOS 16+
//
// /// Compatibility wrapper for NavigationStack with path binding
// @available(iOS 16.0, *)
// struct CompatibleNavigationStackWithPath<Content: View>: View {
//     @Binding var path: [NavigationDestination]
//     let content: Content
//
//     init(path: Binding<[NavigationDestination]>, @ViewBuilder content: () -> Content) {
//         self._path = path
//         self.content = content()
//     }
//
//     var body: some View {
//         NavigationStack(path: $path) {
//             content
//         }
//     }
// }

// MARK: - Navigation Link Helpers

// iOS 16+ navigationDestination support - currently disabled for iOS 15 compatibility
// extension View {
//     /// Compatibility wrapper for navigationDestination modifier
//     @available(iOS 16.0, *)
//     @ViewBuilder
//     func compatibleNavigationDestination<D: Hashable, C: View>(
//         for data: D.Type,
//         @ViewBuilder destination: @escaping (D) -> C
//     ) -> some View {
//         self.navigationDestination(for: data, destination: destination)
//     }
// }

// MARK: - iOS 15 Navigation Helpers

/// For iOS 15, we need to use NavigationLink with explicit tags
/// This can be used in list views to create navigation links
struct CompatibleNavigationLink<Label: View, Destination: View>: View {
    let destination: Destination
    let label: Label

    init(@ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination()
        self.label = label()
    }

    var body: some View {
        NavigationLink(destination: destination) {
            label
        }
    }
}

// MARK: - Navigation Bar Compatibility

extension View {
    /// Compatibility wrapper for toolbar placement
    @ViewBuilder
    func compatibleToolbar<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if #available(iOS 16.0, *) {
            self.toolbar {
                content()
            }
        } else {
            // iOS 15 fallback
            self.toolbar {
                content()
            }
        }
    }
}
