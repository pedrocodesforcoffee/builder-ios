//
//  ProfilePlaceholder.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct ProfilePlaceholder: View {
    @State private var firstName = "John"
    @State private var lastName = "Doe"
    @State private var email = "john.doe@example.com"
    @State private var phoneNumber = "+1 (555) 123-4567"
    @State private var company = "Example Construction"
    @State private var role = "Project Manager"
    @State private var isEditing = false
    @State private var showSaveAlert = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        Button(action: {
                            // Future: Change profile photo
                        }) {
                            Text("Change Photo")
                                .font(.subheadline)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
            .listRowBackground(Color.clear)

            Section("Personal Information") {
                HStack {
                    Text("First Name")
                        .foregroundColor(.secondary)
                    Spacer()
                    if isEditing {
                        TextField("First Name", text: $firstName)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text(firstName)
                    }
                }

                HStack {
                    Text("Last Name")
                        .foregroundColor(.secondary)
                    Spacer()
                    if isEditing {
                        TextField("Last Name", text: $lastName)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text(lastName)
                    }
                }

                HStack {
                    Text("Email")
                        .foregroundColor(.secondary)
                    Spacer()
                    if isEditing {
                        TextField("Email", text: $email)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                    } else {
                        Text(email)
                    }
                }

                HStack {
                    Text("Phone")
                        .foregroundColor(.secondary)
                    Spacer()
                    if isEditing {
                        TextField("Phone", text: $phoneNumber)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                    } else {
                        Text(phoneNumber)
                    }
                }
            }

            Section("Professional Information") {
                HStack {
                    Text("Company")
                        .foregroundColor(.secondary)
                    Spacer()
                    if isEditing {
                        TextField("Company", text: $company)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text(company)
                    }
                }

                HStack {
                    Text("Role")
                        .foregroundColor(.secondary)
                    Spacer()
                    if isEditing {
                        TextField("Role", text: $role)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text(role)
                    }
                }
            }

            Section("Account") {
                Button(action: {
                    // Future: Change password
                }) {
                    HStack {
                        Text("Change Password")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Button(action: {
                    // Future: Delete account
                }) {
                    Text("Delete Account")
                        .foregroundColor(.red)
                }
            }

            Section {
                Text("This is a placeholder view. Profile editing will be fully implemented with API integration in a future update.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        showSaveAlert = true
                    }
                    isEditing.toggle()
                }
            }
        }
        .alert("Profile Updated", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your profile has been updated successfully.")
        }
    }
}

struct ProfilePlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfilePlaceholder()
        }
    }
}
