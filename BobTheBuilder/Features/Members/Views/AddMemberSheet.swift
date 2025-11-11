//
//  AddMemberSheet.swift
//  BobTheBuilder
//
//  Sheet for adding new members to project
//

import SwiftUI

struct AddMemberSheet: View {
    let projectId: String
    let viewModel: ProjectMembersViewModel

    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var permissionService: PermissionService

    @State private var selectedRole: ProjectRole = .viewer
    @State private var selectedUserId = ""
    @State private var selectedUserName = ""
    @State private var searchText = ""
    @State private var hasExpiration = false
    @State private var expirationDate = Date().addingTimeInterval(30 * 86400)
    @State private var expirationReason = ""
    @State private var selectedScope: UserScope?
    @State private var showScopeSelector = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showError = false

    // Mock data for available scope items - in production, fetch from API
    @State private var availableTrades = ["Electrical", "Plumbing", "HVAC", "Framing", "Drywall", "Concrete", "Roofing"]
    @State private var availableAreas = ["Floor 1", "Floor 2", "Floor 3", "Floor 4", "Basement", "Roof"]
    @State private var availablePhases = ["Phase 1 - Foundation", "Phase 2 - Structure", "Phase 3 - MEP", "Phase 4 - Finishes"]

    var body: some View {
        NavigationView {
            Form {
                // User Selection Section
                Section(header: Text("User")) {
                    HStack {
                        TextField("Enter user email or ID...", text: $searchText)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                    }

                    if !searchText.isEmpty {
                        Button("Select: \(searchText)") {
                            selectedUserId = searchText
                            selectedUserName = searchText
                        }
                        .foregroundColor(.blue)
                    }

                    if !selectedUserId.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Selected: \(selectedUserName)")
                                .foregroundColor(.secondary)
                        }
                    }
                } footer: {
                    Text("In production, this would search your organization members")
                        .font(.caption)
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
                }

                // Scope Section (if required)
                if selectedRole.requiresScope {
                    Section(header: Text("Access Scope")) {
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
                    } footer: {
                        Text("This role requires scope assignment to limit access to specific trades, areas, or phases")
                    }
                }

                // Expiration Section
                Section(header: Text("Expiration (Optional)")) {
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
                } footer: {
                    Text("Set for temporary contractors, inspectors, or consultants")
                }
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(isSubmitting)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            await addMember()
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
                Text(errorMessage ?? "Failed to add member")
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

    private var canSubmit: Bool {
        // Must have selected a user
        guard !selectedUserId.isEmpty else { return false }

        // Must have configured scope if role requires it
        if selectedRole.requiresScope {
            guard let scope = selectedScope, !scope.isEmpty else {
                return false
            }
        }

        return true
    }

    private func addMember() async {
        isSubmitting = true
        errorMessage = nil

        do {
            let request = AddMemberRequest(
                projectId: projectId,
                userId: selectedUserId,
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

struct AddMemberRequest: APIRequest {
    typealias Response = ProjectMember

    let projectId: String
    let userId: String
    let role: ProjectRole
    let scope: UserScope?
    let expiresAt: Date?
    let expirationReason: String?

    var path: String {
        "/projects/\(projectId)/members"
    }

    var method: HTTPMethod {
        .post
    }

    var body: [String: Any]? {
        var params: [String: Any] = [
            "userId": userId,
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
        }

        if let expiresAt = expiresAt {
            let formatter = ISO8601DateFormatter()
            params["expiresAt"] = formatter.string(from: expiresAt)
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


