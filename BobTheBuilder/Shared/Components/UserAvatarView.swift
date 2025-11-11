//
//  UserAvatarView.swift
//  BobTheBuilder
//
//  Created on November 10, 2025.
//

import SwiftUI

/// Displays a user avatar with fallback to initials
struct UserAvatarView: View {
    let user: User
    let size: CGFloat

    init(user: User, size: CGFloat = 40) {
        self.user = user
        self.size = size
    }

    var body: some View {
        Group {
            if let avatarURL = user.avatar, let url = URL(string: avatarURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: size, height: size)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        initialsView
                    @unknown default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var initialsView: some View {
        ZStack {
            Circle()
                .fill(colorForUser)

            Text(user.initials)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    private var colorForUser: Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red, .indigo, .teal]
        let index = abs(user.id.hashValue) % colors.count
        return colors[index]
    }
}

// MARK: - Previews

struct UserAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        let mockUser = User(
            id: "1",
            email: "john.doe@example.com",
            firstName: "John",
            lastName: "Doe",
            phoneNumber: "555-1234",
            avatar: nil,
            role: "user",
            organizations: nil,
            createdAt: nil,
            updatedAt: nil
        )

        VStack(spacing: 20) {
            UserAvatarView(user: mockUser, size: 40)
            UserAvatarView(user: mockUser, size: 60)
            UserAvatarView(user: mockUser, size: 80)
        }
        .padding()
    }
}
