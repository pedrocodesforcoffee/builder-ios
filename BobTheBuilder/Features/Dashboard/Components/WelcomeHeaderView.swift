//
//  WelcomeHeaderView.swift
//  BobTheBuilder
//
//  Dashboard welcome header component
//  Created on November 10, 2025.
//

import SwiftUI

struct WelcomeHeaderView: View {
    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        HStack(spacing: 16) {
            // User Avatar
            if let user = authManager.currentUser {
                UserAvatarView(user: user, size: 56)
            }

            // Welcome Text
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                if let user = authManager.currentUser {
                    Text(user.fullName)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                if let primaryRole = authManager.currentUser?.primaryRole {
                    RoleBadgeView(role: primaryRole, size: .small)
                        .padding(.top, 2)
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
}

struct WelcomeHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeHeaderView()
            .previewLayout(.sizeThatFits)
    }
}
