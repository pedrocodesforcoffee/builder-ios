//
//  ScopeInfoCard.swift
//  BobTheBuilder
//
//  Card displaying user's access scope limitations
//

import SwiftUI

struct ScopeInfoCard: View {
    let scope: UserScope

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "scope")
                    .font(.title3)
                    .foregroundColor(.blue)
                Text("Your Access Scope")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            // Scope Items
            VStack(alignment: .leading, spacing: 12) {
                if let trades = scope.trades, !trades.isEmpty {
                    ScopeSection(
                        title: "Trades",
                        icon: "wrench.and.screwdriver",
                        items: trades,
                        color: .blue
                    )
                }

                if let areas = scope.areas, !areas.isEmpty {
                    ScopeSection(
                        title: "Areas",
                        icon: "mappin.and.ellipse",
                        items: areas,
                        color: .green
                    )
                }

                if let phases = scope.phases, !phases.isEmpty {
                    ScopeSection(
                        title: "Phases",
                        icon: "calendar",
                        items: phases,
                        color: .orange
                    )
                }
            }

            // Footer Message
            Text("You can only view and interact with items within your assigned scope")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.blue.opacity(0.05)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        )
        .cornerRadius(12)
    }
}

// MARK: - Scope Section

struct ScopeSection: View {
    let title: String
    let icon: String
    let items: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .foregroundColor(color)
                .font(Font.subheadline.weight(.medium))

            FlowLayout(spacing: 6) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(color.opacity(0.15))
                        .foregroundColor(color)
                        .cornerRadius(6)
                }
            }
        }
    }
}

// MARK: - Flow Layout (iOS 15 Compatible)

// Simple horizontal wrap using HStack - items will wrap naturally in ScrollView
struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        // For iOS 15, just use HStack with wrapping capability
        // This won't auto-wrap but will work for display purposes
        HStack(spacing: spacing) {
            content
        }
    }
}

// MARK: - Preview


