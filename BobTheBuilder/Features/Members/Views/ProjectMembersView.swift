//
//  ProjectMembersView.swift
//  BobTheBuilder
//
//  Project members list with role management
//

import SwiftUI

struct ProjectMembersView: View {
    let projectId: String

    @StateObject private var viewModel: ProjectMembersViewModel
    @EnvironmentObject var permissionService: PermissionService
    @State private var showAddMember = false
    @State private var searchText = ""
    @State private var filterRole: ProjectRole?
    @State private var showFilters = false

    init(projectId: String) {
        self.projectId = projectId
        _viewModel = StateObject(wrappedValue: ProjectMembersViewModel(projectId: projectId))
    }

    var body: some View {
        List {
            // Expiration Warning Section
            if let daysRemaining = permissionService.daysUntilExpiration,
               daysRemaining <= 7 {
                Section {
                    ExpirationWarningBanner(
                        daysRemaining: daysRemaining,
                        expiresAt: permissionService.expiresAt
                    )
                }
                .listRowInsets(EdgeInsets())
            }

            // Scope Info Section
            if let scope = permissionService.scope, !scope.isEmpty {
                Section {
                    ScopeInfoCard(scope: scope)
                }
                .listRowInsets(EdgeInsets())
            }

            // Error Banner Section
            if let error = viewModel.error {
                Section {
                    ErrorBanner(error: error) {
                        await viewModel.refresh()
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            // Members List Section
            Section {
                ForEach(filteredMembers) { member in
                    NavigationLink {
                        MemberDetailView(member: member, projectId: projectId, viewModel: viewModel)
                            .environmentObject(permissionService)
                    } label: {
                        MemberRow(member: member)
                    }
                }
                .onDelete(perform: deleteMember)
            } header: {
                HStack {
                    Text("Members")
                    Spacer()
                    Text("(\(filteredMembers.count))")
                        .foregroundColor(.secondary)
                }
            }

            if viewModel.isLoading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search members...")
        .navigationTitle("Team Members")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showFilters.toggle()
                } label: {
                    Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                }

                Button {
                    showAddMember = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }
                .permissionGuard("project_settings:members:invite")
            }
        }
        .sheet(isPresented: $showAddMember) {
            AddMemberSheet(projectId: projectId, viewModel: viewModel)
                .environmentObject(permissionService)
        }
        .sheet(isPresented: $showFilters) {
            FilterSheet(selectedRole: $filterRole)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadMembers()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }

    // MARK: - Filtered Members

    var filteredMembers: [ProjectMember] {
        var members = viewModel.members

        // Search filter
        if !searchText.isEmpty {
            members = members.filter {
                $0.user.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.user.email.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Role filter
        if let filterRole = filterRole {
            members = members.filter { $0.role == filterRole }
        }

        return members
    }

    // MARK: - Actions

    private func deleteMember(at offsets: IndexSet) {
        guard permissionService.hasPermission("project_settings:members:remove") else {
            return
        }

        for index in offsets {
            let member = filteredMembers[index]
            Task {
                await viewModel.removeMember(member)
            }
        }
    }
}

// MARK: - Member Row

struct MemberRow: View {
    let member: ProjectMember

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AsyncImage(url: member.user.avatarURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Circle()
                    .fill(member.role.color.opacity(0.3))
                    .overlay(
                        Text(member.user.initials)
                            .font(.headline)
                            .foregroundColor(member.role.color)
                    )
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(member.user.fullName)
                    .font(.headline)

                HStack(spacing: 6) {
                    // Role Badge
                    Label(member.role.displayName, systemImage: member.role.icon)
                        .font(.caption)
                        .foregroundColor(member.role.color)

                    // Inherited Badge
                    if member.isInherited {
                        Label("Inherited", systemImage: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }

                    // Scope Badge
                    if let scope = member.scope, !scope.isEmpty {
                        Image(systemName: "scope")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                // Expiration
                if let expiresAt = member.expiresAt {
                    ExpirationLabel(expiresAt: expiresAt)
                }
            }

            Spacer()

            // Status Indicator
            MemberStatusIndicator(member: member)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Supporting Views

struct ExpirationLabel: View {
    let expiresAt: Date

    var body: some View {
        let daysRemaining = Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: expiresAt
        ).day ?? 0

        HStack(spacing: 4) {
            Image(systemName: daysRemaining <= 0 ? "exclamationmark.triangle.fill" : "clock")
                .font(.caption2)

            if daysRemaining <= 0 {
                Text("Expired")
            } else if daysRemaining <= 7 {
                Text("\(daysRemaining)d remaining")
            } else {
                Text("Expires \(expiresAt.formatted(date: .abbreviated, time: .omitted))")
            }
        }
        .font(.caption)
        .foregroundColor(daysRemaining <= 0 ? .red : daysRemaining <= 7 ? .orange : .secondary)
    }
}

struct MemberStatusIndicator: View {
    let member: ProjectMember

    var body: some View {
        let isExpired = member.expiresAt.map { Date() > $0 } ?? false

        Circle()
            .fill(isExpired ? Color.red : member.isInherited ? Color.orange : Color.green)
            .frame(width: 8, height: 8)
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Binding var selectedRole: ProjectRole?
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Filter by Role")) {
                    Button {
                        selectedRole = nil
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Text("All Roles")
                            Spacer()
                            if selectedRole == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)

                    ForEach(ProjectRole.allCases) { role in
                        Button {
                            selectedRole = role
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Label {
                                    Text(role.displayName)
                                } icon: {
                                    Image(systemName: role.icon)
                                        .foregroundColor(role.color)
                                }
                                Spacer()
                                if selectedRole == role {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview


