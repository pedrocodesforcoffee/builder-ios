//
//  ProjectListView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct ProjectListView: View {
    @StateObject private var navigationManager = NavigationPathManager.shared
    @State private var searchText = ""

    // Placeholder data
    private let sampleProjects = [
        ("1", "Main Street Office Building", "Active"),
        ("2", "Riverside Apartments", "Planning"),
        ("3", "City Center Renovation", "Active"),
        ("4", "Harbor View Complex", "On Hold")
    ]

    var body: some View {
        List {
            ForEach(filteredProjects, id: \.0) { project in
                ProjectRow(
                    title: project.1,
                    status: project.2
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    navigationManager.navigate(to: .projectDetail(projectId: project.0))
                }
            }
        }
        .navigationTitle("Projects")
        .searchable(text: $searchText, prompt: "Search projects")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    navigationManager.navigate(to: .createProject)
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if sampleProjects.isEmpty {
                emptyStateView
            }
        }
    }

    private var filteredProjects: [(String, String, String)] {
        if searchText.isEmpty {
            return sampleProjects
        } else {
            return sampleProjects.filter { $0.1.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Projects Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tap + to create your first project")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button(action: {
                navigationManager.navigate(to: .createProject)
            }) {
                Label("Create Project", systemImage: "plus")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
    }
}

struct ProjectRow: View {
    let title: String
    let status: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            HStack {
                StatusBadge(status: status)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
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
        case "Active": return .green
        case "Planning": return .blue
        case "On Hold": return .orange
        case "Completed": return .gray
        default: return .gray
        }
    }
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectListView()
        }
    }
}
