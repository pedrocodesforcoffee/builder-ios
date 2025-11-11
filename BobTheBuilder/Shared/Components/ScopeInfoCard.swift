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
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)

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

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            let position = result.positions[index]
            subview.place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Preview


