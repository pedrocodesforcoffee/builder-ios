//
//  RFIListView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct RFIListView: View {
    @StateObject private var viewModel = RFIListViewModel()
    @StateObject private var navigationManager = NavigationPathManager.shared
    @State private var searchText = ""
    @State private var filterStatus: RFIFilterStatus = .all

    var body: some View {
        ProtectedView(requiresAuth: true) {
            ZStack {
                if viewModel.viewState.isLoading {
                    LoadingStateView(message: "Loading RFIs...")
                } else if viewModel.viewState.isEmpty {
                    EmptyStateView(
                        icon: "doc.text.fill",
                        title: "No RFIs Yet",
                        message: "Tap + to create your first RFI",
                        actionTitle: "Create RFI",
                        action: {
                            navigationManager.navigate(to: .createRFI(projectId: "1"))
                        }
                    )
                } else if let error = viewModel.viewState.error {
                    ErrorStateView(
                        error: error.localizedDescription,
                        retry: {
                            viewModel.loadRFIs()
                        }
                    )
                } else if let rfis = viewModel.viewState.data {
                    rfiList(rfis: rfis)
                }
            }
            .navigationTitle("RFIs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            navigationManager.navigate(to: .createRFI(projectId: "1"))
                        }) {
                            Label("New RFI", systemImage: "plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.loadRFIs()
            }
            .refreshable {
                await viewModel.refreshRFIs()
            }
        }
    }

    private func rfiList(rfis: [RFI]) -> some View {
        List {
            Section {
                Picker("Filter", selection: $filterStatus) {
                    ForEach(RFIFilterStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
            }

            ForEach(filteredRFIs(rfis)) { rfi in
                RFIRow(rfi: rfi)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigationManager.navigate(to: .rfiDetail(rfiId: rfi.id))
                    }
            }
        }
        .searchable(text: $searchText, prompt: "Search RFIs")
    }

    private func filteredRFIs(_ rfis: [RFI]) -> [RFI] {
        var filtered = rfis

        // Filter by status
        if filterStatus != .all {
            filtered = filtered.filter { rfi in
                switch filterStatus {
                case .all:
                    return true
                case .draft:
                    return rfi.status == .draft
                case .pending:
                    return rfi.status == .pending
                case .answered:
                    return rfi.status == .answered
                case .closed:
                    return rfi.status == .closed
                }
            }
        }

        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.subject.localizedCaseInsensitiveContains(searchText) }
        }

        return filtered
    }
}

enum RFIFilterStatus: String, CaseIterable {
    case all = "All"
    case draft = "Draft"
    case pending = "Pending"
    case answered = "Answered"
    case closed = "Closed"
}

// MARK: - RFI List View Model

class RFIListViewModel: ObservableObject {
    @Published var viewState: ViewState<[RFI]> = .idle

    func loadRFIs() {
        guard viewState.isIdle else { return }

        viewState = .loading

        // Simulate API call
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

            await MainActor.run {
                let rfis = RFI.mockRFIs

                if rfis.isEmpty {
                    viewState = .empty
                } else {
                    viewState = .loaded(rfis)
                }
            }
        }
    }

    func refreshRFIs() async {
        // Simulate API call without showing loading state
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        await MainActor.run {
            let rfis = RFI.mockRFIs

            if rfis.isEmpty {
                viewState = .empty
            } else {
                viewState = .loaded(rfis)
            }
        }
    }
}

// MARK: - RFI Row

struct RFIRow: View {
    let rfi: RFI

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RFI #\(rfi.number)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(rfi.subject)
                        .font(.headline)
                }
                Spacer()
                Image(systemName: rfi.status.icon)
                    .foregroundColor(rfi.status.color)
            }

            HStack {
                RFIStatusBadge(status: rfi.status.rawValue, color: rfi.status.color)

                PriorityBadge(priority: rfi.priority)

                Spacer()

                if let dueDate = rfi.dueDate {
                    Label(
                        dueDate.formatted(date: .abbreviated, time: .omitted),
                        systemImage: rfi.isOverdue ? "exclamationmark.triangle.fill" : "calendar"
                    )
                    .font(.caption)
                    .foregroundColor(rfi.isOverdue ? .red : .secondary)
                } else {
                    Text(formattedCreatedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(rfi.project)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var formattedCreatedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: rfi.createdDate, relativeTo: Date())
    }
}

// MARK: - Status and Priority Badges

struct RFIStatusBadge: View {
    let status: String
    let color: Color

    var body: some View {
        Text(status)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .cornerRadius(8)
    }
}

struct PriorityBadge: View {
    let priority: RFI.Priority

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: priority.icon)
                .font(.system(size: 10))
            Text(priority.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(priority.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(priority.color.opacity(0.2))
        .cornerRadius(8)
    }
}

// MARK: - Previews

struct RFIListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RFIListView()
        }
    }
}

struct RFIRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            RFIRow(rfi: RFI.sample)
            RFIRow(rfi: RFI.mockRFIs[1])
            RFIRow(rfi: RFI.mockRFIs[3])
        }
    }
}
