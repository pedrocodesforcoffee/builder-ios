//
//  RFIListView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct RFIListView: View {
    @StateObject private var navigationManager = NavigationPathManager.shared
    @State private var searchText = ""
    @State private var filterStatus: RFIStatus = .all

    // Placeholder data
    private let sampleRFIs = [
        ("1", "Electrical wiring specifications", "1", "Open", Date()),
        ("2", "Foundation depth clarification", "1", "Pending", Date().addingTimeInterval(-86400)),
        ("3", "HVAC system requirements", "2", "Resolved", Date().addingTimeInterval(-172800)),
        ("4", "Window glazing type", "3", "Open", Date().addingTimeInterval(-259200))
    ]

    var body: some View {
        List {
            Section {
                Picker("Filter", selection: $filterStatus) {
                    ForEach(RFIStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
            }

            ForEach(filteredRFIs, id: \.0) { rfi in
                RFIRow(
                    title: rfi.1,
                    status: rfi.3,
                    date: rfi.4
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    navigationManager.navigate(to: .rfiDetail(rfiId: rfi.0))
                }
            }
        }
        .navigationTitle("RFIs")
        .searchable(text: $searchText, prompt: "Search RFIs")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        // Navigate to create RFI - need to select project first
                        navigationManager.navigate(to: .createRFI(projectId: "1"))
                    }) {
                        Label("New RFI", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if sampleRFIs.isEmpty {
                emptyStateView
            }
        }
    }

    private var filteredRFIs: [(String, String, String, String, Date)] {
        var rfis = sampleRFIs

        // Filter by status
        if filterStatus != .all {
            rfis = rfis.filter { $0.3 == filterStatus.rawValue }
        }

        // Filter by search text
        if !searchText.isEmpty {
            rfis = rfis.filter { $0.1.localizedCaseInsensitiveContains(searchText) }
        }

        return rfis
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No RFIs Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tap + to create your first RFI")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button(action: {
                navigationManager.navigate(to: .createRFI(projectId: "1"))
            }) {
                Label("Create RFI", systemImage: "plus")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
    }
}

enum RFIStatus: String, CaseIterable {
    case all = "All"
    case open = "Open"
    case pending = "Pending"
    case resolved = "Resolved"
}

struct RFIRow: View {
    let title: String
    let status: String
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            HStack {
                RFIStatusBadge(status: status)
                Spacer()
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct RFIStatusBadge: View {
    let status: String

    var body: some View {
        Text(status)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .cornerRadius(8)
    }

    private var statusColor: Color {
        switch status {
        case "Open": return .red
        case "Pending": return .orange
        case "Resolved": return .green
        default: return .gray
        }
    }
}

struct RFIListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RFIListView()
        }
    }
}
