//
//  RFIDetailPlaceholder.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct RFIDetailPlaceholder: View {
    let rfiId: String

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    Text("RFI Detail")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("RFI #\(rfiId)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)

                // RFI Info
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Subject")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Electrical wiring specifications")
                            .font(.headline)
                    }

                    Divider()

                    InfoRow(label: "Status", value: "Open")
                    InfoRow(label: "Priority", value: "High")
                    InfoRow(label: "Created", value: "2 days ago")
                    InfoRow(label: "Project", value: "Main Street Office")
                    InfoRow(label: "Assigned To", value: "John Smith")

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Need clarification on electrical wiring specifications for floors 3-5. Current plans show conflicting information regarding conduit sizes.")
                            .font(.body)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        // Future: Add response
                    }) {
                        Label("Add Response", systemImage: "text.bubble.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: {
                        // Future: Add attachments
                    }) {
                        Label("Add Attachments", systemImage: "paperclip")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(action: {
                        // Future: Change status
                    }) {
                        Label("Update Status", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)

                // Responses Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Responses")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        ResponseCard(
                            author: "Jane Doe",
                            date: "1 day ago",
                            message: "I'll review the plans and get back to you with clarification by end of day."
                        )
                        ResponseCard(
                            author: "Mike Johnson",
                            date: "6 hours ago",
                            message: "Updated plans have been uploaded to the document center."
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.top)

                Spacer()

                // Placeholder note
                Text("This is a placeholder view.\nFull RFI details will be implemented in a future update.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .navigationTitle("RFI")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ResponseCard: View {
    let author: String
    let date: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.blue)
                Text(author)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(message)
                .font(.body)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct RFIDetailPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RFIDetailPlaceholder(rfiId: "123")
        }
    }
}
