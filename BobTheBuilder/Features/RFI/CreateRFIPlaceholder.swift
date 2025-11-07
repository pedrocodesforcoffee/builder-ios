//
//  CreateRFIPlaceholder.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct CreateRFIPlaceholder: View {
    let projectId: String
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var subject = ""
    @State private var description = ""
    @State private var priority = "Medium"
    @State private var assignedTo = ""
    @State private var showSuccessAlert = false

    let priorities = ["Low", "Medium", "High", "Critical"]

    var body: some View {
        Form {
            Section("RFI Information") {
                TextField("Subject", text: $subject)
                TextField("Description", text: $description)
                    .lineLimit(5)
            }

            Section("Details") {
                Picker("Priority", selection: $priority) {
                    ForEach(priorities, id: \.self) { priority in
                        Text(priority).tag(priority)
                    }
                }
                TextField("Assign To", text: $assignedTo)
                    .textContentType(.name)
            }

            Section("Project") {
                HStack {
                    Text("Project ID")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(projectId)
                }
                Text("Main Street Office Building")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Section("Attachments") {
                Button(action: {
                    // Future: Add attachments
                }) {
                    Label("Add Attachments", systemImage: "paperclip")
                }
            }

            Section {
                Button(action: {
                    showSuccessAlert = true
                }) {
                    HStack {
                        Spacer()
                        Text("Submit RFI")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(subject.isEmpty || description.isEmpty)
            }

            Section {
                Text("This is a placeholder form. Actual RFI creation will be implemented with API integration in a future update.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("New RFI")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alert("RFI Created", isPresented: $showSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your RFI '\(subject)' has been submitted successfully.")
        }
    }
}

// Preview disabled due to @Environment property wrapper
// struct CreateRFIPlaceholder_Previews: PreviewProvider {
//     static var previews: some View {
//         NavigationView {
//             CreateRFIPlaceholder(projectId: "123")
//         }
//     }
// }
