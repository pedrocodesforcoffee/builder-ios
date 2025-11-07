//
//  ProjectListView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct ProjectListView: View {
    @StateObject private var viewModel = ProjectListViewModel()
    @StateObject private var navigationManager = NavigationPathManager.shared
    @State private var searchText = ""

    var body: some View {
        ZStack {
            if viewModel.viewState.isLoading {
                LoadingStateView(message: "Loading projects...")
            } else if viewModel.viewState.isEmpty {
                EmptyStateView(
                    icon: "hammer.fill",
                    title: "No Projects Yet",
                    message: "Tap + to create your first project",
                    actionTitle: "Create Project",
                    action: {
                        navigationManager.navigate(to: .createProject)
                    }
                )
            } else if let error = viewModel.viewState.error {
                ErrorStateView(
                    error: error.localizedDescription,
                    retry: {
                        viewModel.loadProjects()
                    }
                )
            } else if let projects = viewModel.viewState.data {
                projectList(projects: projects)
            }
        }
        .navigationTitle("Projects")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    navigationManager.navigate(to: .createProject)
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            viewModel.loadProjects()
        }
        .refreshable {
            await viewModel.refreshProjects()
        }
    }

    private func projectList(projects: [Project]) -> some View {
        List {
            ForEach(filteredProjects(projects)) { project in
                ProjectRow(project: project)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigationManager.navigate(to: .projectDetail(projectId: project.id))
                    }
            }
        }
        .searchable(text: $searchText, prompt: "Search projects")
    }

    private func filteredProjects(_ projects: [Project]) -> [Project] {
        if searchText.isEmpty {
            return projects
        } else {
            return projects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

// MARK: - Project List View Model

class ProjectListViewModel: ObservableObject {
    @Published var viewState: ViewState<[Project]> = .idle

    func loadProjects() {
        guard viewState.isIdle else { return }

        viewState = .loading

        // Simulate API call
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

            await MainActor.run {
                let projects = Project.mockProjects

                if projects.isEmpty {
                    viewState = .empty
                } else {
                    viewState = .loaded(projects)
                }
            }
        }
    }

    func refreshProjects() async {
        // Simulate API call without showing loading state
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        await MainActor.run {
            let projects = Project.mockProjects

            if projects.isEmpty {
                viewState = .empty
            } else {
                viewState = .loaded(projects)
            }
        }
    }
}

// MARK: - Project Row

struct ProjectRow: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(project.name)
                    .font(.headline)
                Spacer()
                Image(systemName: project.status.icon)
                    .foregroundColor(project.status.color)
            }

            HStack {
                StatusBadge(status: project.status.rawValue, color: project.status.color)

                if let location = project.location {
                    Text("•")
                        .foregroundColor(.secondary)
                    Label(location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if let dueDate = project.dueDate {
                    Label(
                        dueDate.formatted(date: .abbreviated, time: .omitted),
                        systemImage: "calendar"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }

            if project.progress > 0 {
                ProgressView(value: project.progress)
                    .tint(project.status.color)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
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

// MARK: - Previews

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectListView()
        }
    }
}

struct ProjectRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ProjectRow(project: Project.sample)
            ProjectRow(project: Project.mockProjects[1])
            ProjectRow(project: Project.mockProjects[2])
        }
    }
}
