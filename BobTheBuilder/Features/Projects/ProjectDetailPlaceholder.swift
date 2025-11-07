//
//  ProjectDetailPlaceholder.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct ProjectDetailPlaceholder: View {
    let projectId: String
    @StateObject private var navigationManager = NavigationPathManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    Text("Project Detail")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("ID: \(projectId)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)

                // Project Info
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(label: "Name", value: "Main Street Office Building")
                    InfoRow(label: "Status", value: "Active")
                    InfoRow(label: "Start Date", value: "Jan 15, 2024")
                    InfoRow(label: "Completion", value: "85%")
                    InfoRow(label: "Location", value: "123 Main St, City")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        navigationManager.navigate(to: .createRFI(projectId: projectId))
                    }) {
                        Label("Create RFI", systemImage: "doc.text.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: {
                        // Future: View project documents
                    }) {
                        Label("View Documents", systemImage: "folder.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(action: {
                        // Future: View project team
                    }) {
                        Label("View Team", systemImage: "person.3.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)

                Spacer()

                // Placeholder note
                Text("This is a placeholder view.\nFull project details will be implemented in a future update.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .navigationTitle("Project")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct ProjectDetailPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectDetailPlaceholder(projectId: "123")
        }
    }
}
