//
//  EditMemberSheet.swift
//  BobTheBuilder
//
//  Sheet for editing existing member roles and permissions
//

import SwiftUI

struct EditMemberSheet: View {
    let member: ProjectMember
    let projectId: String
    let viewModel: ProjectMembersViewModel

    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var permissionService: PermissionService

    @State private var selectedRole: ProjectRole
    @State private var hasExpiration: Bool
    @State private var expirationDate: Date
    @State private var expirationReason: String
    @State private var selectedScope: UserScope?
    @State private var showScopeSelector = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showError = false

    // Mock data for available scope items
    @State private var availableTrades = ["Electrical", "Plumbing", "HVAC", "Framing", "Drywall", "Concrete", "Roofing"]
    @State private var availableAreas = ["Floor 1", "Floor 2", "Floor 3", "Floor 4", "Basement", "Roof"]
    @State private var availablePhases = ["Phase 1 - Foundation", "Phase 2 - Structure", "Phase 3 - MEP", "Phase 4 - Finishes"]

    init(member: ProjectMember, projectId: String, viewModel: ProjectMembersViewModel) {
        self.member = member
        self.projectId = projectId
        self.viewModel = viewModel

        // Initialize state from member
        _selectedRole = State(initialValue: member.role)
        _hasExpiration = State(initialValue: member.expiresAt != nil)
        _expirationDate = State(initialValue: member.expiresAt ?? Date().addingTimeInterval(30 * 86400))
        _expirationReason = State(initialValue: member.expirationReason ?? "")
        _selectedScope = State(initialValue: member.scope)
    }

    var body: some View {
        NavigationView {
            Form {
                // Member Info Section
                Section(header: Text("Member")) {
                    HStack(spacing: 12) {
                        if let avatarURL = member.user.avatar, let url = URL(string: avatarURL) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Circle()
                                    .fill(member.role.color.opacity(0.3))
                                    .overlay(
                                        Text(member.user.initials)
                                            .font(.title3)
                                            .foregroundColor(member.role.color)
                                    )
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(member.role.color.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(member.user.initials)
                                        .font(.title3)
                                        .foregroundColor(member.role.color)
                                )
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(member.user.fullName)
                                .font(.headline)
                            Text(member.user.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Role Selection
                Section(header: Text("Role")) {
                    Picker("Select Role", selection: $selectedRole) {
                        ForEach(ProjectRole.allCases) { role in
                            Label {
                                Text(role.displayName)
                            } icon: {
                                Image(systemName: role.icon)
                                    .foregroundColor(role.color)
                            }
                            .tag(role)
                        }
                    }
                    .pickerStyle(.automatic)
                    .onChange(of: selectedRole) { newValue in
                        // Clear scope when switching to a role that doesn't require it
                        if !newValue.requiresScope {
                            selectedScope = nil
                        }
                    }

                    Text(selectedRole.description)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if selectedRole != member.role {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Role will change from \(member.role.displayName)")
                                .font(.caption)
                        }
                    }
                }

                // Scope Section
                if selectedRole.requiresScope {
                    Section(
                        header: Text("Access Scope"),
                        footer: Text("This role requires scope assignment to limit access")
                    ) {
                        Button {
                            showScopeSelector = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Configure Scope")
                                        .foregroundColor(.primary)

                                    if let scope = selectedScope, !scope.isEmpty {
                                        HStack(spacing: 8) {
                                            if let trades = scope.trades, !trades.isEmpty {
                                                Text("\(trades.count) trade\(trades.count == 1 ? "" : "s")")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                            if let areas = scope.areas, !areas.isEmpty {
                                                Text("\(areas.count) area\(areas.count == 1 ? "" : "s")")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                            }
                                            if let phases = scope.phases, !phases.isEmpty {
                                                Text("\(phases.count) phase\(phases.count == 1 ? "" : "s")")
                                                    .font(.caption)
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                    } else {
                                        Text("Not configured")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()

                                if selectedScope == nil || selectedScope?.isEmpty == true {
                                    Text("Required")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                // Expiration Section
                Section(
                    header: Text("Expiration"),
                    footer: member.expiresAt != nil && !hasExpiration ?
                        Text("Removing expiration will grant permanent access") :
                        Text("Set for temporary access periods")
                ) {
                    Toggle("Set Expiration Date", isOn: $hasExpiration)

                    if hasExpiration {
                        DatePicker(
                            "Expires On",
                            selection: $expirationDate,
                            in: Date()...,
                            displayedComponents: .date
                        )

                        TextField("Reason (optional)", text: $expirationReason)
                    }
                }

                // Change Summary
                if hasChanges {
                    Section(header: Text("Changes")) {
                        if selectedRole != member.role {
                            HStack {
                                Text("Role")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(member.role.displayName)
                                    .strikethrough()
                                    .foregroundColor(.red)
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                Text(selectedRole.displayName)
                                    .foregroundColor(.green)
                            }
                            .font(.caption)
                        }

                        if selectedScope != member.scope {
                            HStack {
                                Text("Scope")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Modified")
                                    .foregroundColor(.orange)
                            }
                            .font(.caption)
                        }

                        if (hasExpiration && member.expiresAt == nil) ||
                           (!hasExpiration && member.expiresAt != nil) ||
                           (hasExpiration && expirationDate != member.expiresAt) {
                            HStack {
                                Text("Expiration")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Modified")
                                    .foregroundColor(.orange)
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Edit Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(isSubmitting)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await updateMember()
                        }
                    }
                    .disabled(!canSubmit || isSubmitting)
                }
            }
            .sheet(isPresented: $showScopeSelector) {
                ScopeSelectorView(
                    projectId: projectId,
                    selectedScope: $selectedScope,
                    availableTrades: availableTrades,
                    availableAreas: availableAreas,
                    availablePhases: availablePhases
                )
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Failed to update member")
            }
            .overlay {
                if isSubmitting {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(1.5)
                    }
                }
            }
        }
    }

    private var hasChanges: Bool {
        // Check if any field has changed
        if selectedRole != member.role { return true }
        if selectedScope != member.scope { return true }
        if hasExpiration != (member.expiresAt != nil) { return true }
        if hasExpiration, let memberExpiry = member.expiresAt {
            // Compare dates (ignoring time component for simplicity)
            let calendar = Calendar.current
            let memberDate = calendar.startOfDay(for: memberExpiry)
            let selectedDate = calendar.startOfDay(for: expirationDate)
            if memberDate != selectedDate { return true }
        }
        if hasExpiration && expirationReason != (member.expirationReason ?? "") { return true }
        return false
    }

    private var canSubmit: Bool {
        // Must have changes
        guard hasChanges else { return false }

        // Must have configured scope if role requires it
        if selectedRole.requiresScope {
            guard let scope = selectedScope, !scope.isEmpty else {
                return false
            }
        }

        return true
    }

    private func updateMember() async {
        isSubmitting = true
        errorMessage = nil

        do {
            let request = UpdateMemberRequest(
                projectId: projectId,
                userId: member.user.id,
                role: selectedRole,
                scope: selectedRole.requiresScope ? selectedScope : nil,
                expiresAt: hasExpiration ? expirationDate : nil,
                expirationReason: hasExpiration && !expirationReason.isEmpty ? expirationReason : nil
            )

            _ = try await APIClient.shared.execute(request)

            // Refresh the member list
            await viewModel.loadMembers()

            isSubmitting = false
            presentationMode.wrappedValue.dismiss()
        } catch {
            isSubmitting = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - API Request

struct UpdateMemberRequest: APIRequest {
    typealias Response = ProjectMember

    let projectId: String
    let userId: String
    let role: ProjectRole
    let scope: UserScope?
    let expiresAt: Date?
    let expirationReason: String?

    var path: String {
        "/projects/\(projectId)/members/\(userId)"
    }

    var method: HTTPMethod {
        .patch
    }

    var body: [String: Any]? {
        var params: [String: Any] = [
            "role": role.rawValue
        ]

        if let scope = scope {
            var scopeDict: [String: Any] = [:]
            if let trades = scope.trades {
                scopeDict["trades"] = trades
            }
            if let areas = scope.areas {
                scopeDict["areas"] = areas
            }
            if let phases = scope.phases {
                scopeDict["phases"] = phases
            }
            params["scope"] = scopeDict
        } else {
            // Explicitly clear scope if role doesn't require it
            params["scope"] = NSNull()
        }

        if let expiresAt = expiresAt {
            let formatter = ISO8601DateFormatter()
            params["expiresAt"] = formatter.string(from: expiresAt)
        } else {
            // Explicitly clear expiration if not set
            params["expiresAt"] = NSNull()
        }

        if let reason = expirationReason {
            params["expirationReason"] = reason
        }

        return params
    }

    var requiresAuth: Bool {
        true
    }
}

// MARK: - Preview


