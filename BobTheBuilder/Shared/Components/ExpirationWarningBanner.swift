//
//  ExpirationWarningBanner.swift
//  BobTheBuilder
//
//  Warning banner for expiring access
//

import SwiftUI

struct ExpirationWarningBanner: View {
    let daysRemaining: Int
    let expiresAt: Date?

    @State private var showRenewalSheet = false

    var body: some View {
        Group {
            if daysRemaining <= 0 {
                // Expired
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                        Text("Access Expired")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)

                    Text("Your project access expired on \(expiresAt?.formatted(date: .long, time: .omitted) ?? "N/A"). Contact your administrator to extend your access.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))

                    Button {
                        showRenewalSheet = true
                    } label: {
                        Text("Request Extension")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color.red, Color.red.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .shadow(radius: 4)
            } else if daysRemaining <= 7 {
                // Expiring soon
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.title2)
                        Text("Access Expiring Soon")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)

                    Text("Your project access will expire in \(daysRemaining) day\(daysRemaining == 1 ? "" : "s"). Plan ahead to maintain uninterrupted access.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))

                    if daysRemaining <= 3 {
                        Button {
                            showRenewalSheet = true
                        } label: {
                            Text("Request Extension")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color.orange, Color.orange.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .shadow(radius: 4)
            }
        }
        .sheet(isPresented: $showRenewalSheet) {
            RenewalRequestSheet()
        }
    }
}

// MARK: - Renewal Request Sheet

struct RenewalRequestSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var reason = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationView {
            Form {
                Section("Request Details") {
                    TextEditor(text: $reason)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if reason.isEmpty {
                                    Text("Explain why you need continued access...")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                }

                Section {
                    Button {
                        submitRequest()
                    } label: {
                        if isSubmitting {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Submit Request")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(reason.isEmpty || isSubmitting)
                }
            }
            .navigationTitle("Request Extension")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func submitRequest() {
        isSubmitting = true
        // TODO: Implement API call to submit renewal request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSubmitting = false
            dismiss()
        }
    }
}

// MARK: - Preview




