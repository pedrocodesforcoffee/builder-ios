//
//  MemberDetailView.swift
//  BobTheBuilder
//
//  Detailed view of a project member
//

import SwiftUI

struct MemberDetailView: View {
    let member: ProjectMember
    let projectId: String
    let viewModel: ProjectMembersViewModel

    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var permissionService: PermissionService
    @State private var showEditSheet = false
    @State private var showRemoveAlert = false
    @State private var isRemoving = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            // User Info Section
            Section {
                HStack(spacing: 16) {
                    AsyncImage(url: member.user.avatarURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(member.role.color.opacity(0.3))
                            .overlay(
                                Text(member.user.initials)
                                    .font(.title)
                                    .foregroundColor(member.role.color)
                            )
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 8) {
                        Text(member.user.fullName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(member.user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            // Role Section
            Section(header: Text("Role")) {
                HStack {
                    Image(systemName: member.role.icon)
                        .foregroundColor(member.role.color)
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(member.role.displayName)
                            .font(.headline)

                        Text(member.role.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if member.isInherited {
                        Label("Inherited", systemImage: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }

            // Scope Section
            if let scope = member.scope, !scope.isEmpty {
                Section(header: Text("Access Scope")) {
                    if let trades = scope.trades, !trades.isEmpty {
                        DisclosureGroup {
                            ForEach(trades, id: \.self) { trade in
                                Label(trade, systemImage: "wrench.and.screwdriver")
                            }
                        } label: {
                            Text("Trades (\(trades.count))")
                        }
                    }

                    if let areas = scope.areas, !areas.isEmpty {
                        DisclosureGroup {
                            ForEach(areas, id: \.self) { area in
                                Label(area, systemImage: "mappin.and.ellipse")
                            }
                        } label: {
                            Text("Areas (\(areas.count))")
                        }
                    }

                    if let phases = scope.phases, !phases.isEmpty {
                        DisclosureGroup {
                            ForEach(phases, id: \.self) { phase in
                                Label(phase, systemImage: "calendar")
                            }
                        } label: {
                            Text("Phases (\(phases.count))")
                        }
                    }
                }
            }

            // Expiration Section
            if let expiresAt = member.expiresAt {
                Section(header: Text("Access Expiration")) {
                    let daysRemaining = member.daysUntilExpiration ?? 0

                    HStack {
                        Image(systemName: daysRemaining <= 0 ? "exclamationmark.triangle.fill" : "clock")
                            .foregroundColor(daysRemaining <= 0 ? .red : daysRemaining <= 7 ? .orange : .blue)

                        VStack(alignment: .leading) {
                            Text(daysRemaining <= 0 ? "Expired" : "Expires on")
                                .font(.subheadline)

                            Text(expiresAt.formatted(date: .long, time: .omitted))
                                .font(.headline)
                        }

                        Spacer()

                        if daysRemaining > 0 {
                            Text("\(daysRemaining) days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if let reason = member.expirationReason {
                        Text(reason)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Membership Details
            Section(header: Text("Membership")) {
                HStack {
                    Text("Joined")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(member.joinedAt.formatted(date: .long, time: .omitted))
                }

                if let invitedBy = member.invitedBy {
                    HStack {
                        Text("Invited By")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(invitedBy.fullName)
                    }
                }
            }

            // Actions Section
            if !member.isInherited {
                Section {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Edit Role", systemImage: "pencil")
                    }
                    .requirePermission(
                        "project_settings:members:update",
                        message: "You need admin permissions to edit member roles"
                    )

                    Button(role: .destructive) {
                        showRemoveAlert = true
                    } label: {
                        Label("Remove from Project", systemImage: "person.badge.minus")
                    }
                    .requirePermission(
                        "project_settings:members:remove",
                        message: "You need admin permissions to remove members"
                    )
                } footer: {
                    if member.isInherited {
                        Text("Inherited roles cannot be modified at the project level")
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Member Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            EditMemberSheet(
                member: member,
                projectId: projectId,
                viewModel: viewModel
            )
            .environmentObject(permissionService)
        }
        .alert("Remove Member", isPresented: $showRemoveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                Task {
                    await removeMember()
                }
            }
        } message: {
            Text("Are you sure you want to remove \(member.user.fullName) from this project? This action cannot be undone.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Failed to remove member")
        }
        .overlay {
            if isRemoving {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("Removing member...")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                }
            }
        }
    }

    private func removeMember() async {
        isRemoving = true

        await viewModel.removeMember(member)

        isRemoving = false

        // Check if error occurred
        if let error = viewModel.error {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        } else {
            // Only dismiss if no error occurred
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Preview


