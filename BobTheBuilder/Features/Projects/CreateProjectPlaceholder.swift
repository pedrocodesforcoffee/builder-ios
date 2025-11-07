//
//  CreateProjectPlaceholder.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct CreateProjectPlaceholder: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var projectName = ""
    @State private var projectDescription = ""
    @State private var startDate = Date()
    @State private var selectedStatus = "Planning"
    @State private var showSuccessAlert = false

    let statuses = ["Planning", "Active", "On Hold", "Completed"]

    var body: some View {
        Form {
            Section("Project Information") {
                TextField("Project Name", text: $projectName)
                TextField("Description", text: $projectDescription)
                    .lineLimit(3)
            }

            Section("Details") {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                Picker("Status", selection: $selectedStatus) {
                    ForEach(statuses, id: \.self) { status in
                        Text(status).tag(status)
                    }
                }
            }

            Section("Location") {
                TextField("Address", text: .constant(""))
                TextField("City", text: .constant(""))
                TextField("State", text: .constant(""))
                TextField("ZIP Code", text: .constant(""))
            }

            Section {
                Button(action: {
                    showSuccessAlert = true
                }) {
                    HStack {
                        Spacer()
                        Text("Create Project")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(projectName.isEmpty)
            }

            Section {
                Text("This is a placeholder form. Actual project creation will be implemented with API integration in a future update.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("New Project")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alert("Project Created", isPresented: $showSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your project '\(projectName)' has been created successfully.")
        }
    }
}

// Preview disabled due to @Environment property wrapper
// struct CreateProjectPlaceholder_Previews: PreviewProvider {
//     static var previews: some View {
//         NavigationView {
//             CreateProjectPlaceholder()
//         }
//     }
// }
