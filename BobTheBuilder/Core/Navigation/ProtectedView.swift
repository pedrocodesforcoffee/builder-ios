//
//  ProtectedView.swift
//  BobTheBuilder
//
//  Created on November 9, 2025.
//

import SwiftUI

struct ProtectedView<Content: View>: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var coordinator = AppCoordinator.shared
    @ViewBuilder let content: Content
    let requiresAuth: Bool

    init(requiresAuth: Bool = true, @ViewBuilder content: () -> Content) {
        self.requiresAuth = requiresAuth
        self.content = content()
    }

    var body: some View {
        Group {
            if requiresAuth && !authManager.isAuthenticated {
                unauthorizedView
            } else if coordinator.requiresReauthentication {
                reauthenticationView
            } else {
                content
            }
        }
        .animation(.easeInOut, value: authManager.isAuthenticated)
        .animation(.easeInOut, value: coordinator.requiresReauthentication)
    }

    private var unauthorizedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Authentication Required")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Please sign in to access this content")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                // Navigate to login
                coordinator.logout()
            }) {
                Text("Sign In")
                    .fontWeight(.medium)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }

    private var reauthenticationView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Session Expired")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Your session has expired. Please sign in again to continue.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                coordinator.logout()
            }) {
                Text("Sign In Again")
                    .fontWeight(.medium)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}
