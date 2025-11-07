//
//  AboutPlaceholder.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct AboutPlaceholder: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // App Icon and Name
                VStack(spacing: 16) {
                    Image(systemName: "hammer.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)
                    Text("Bob the Builder")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Version \(appVersion)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // About Text
                VStack(alignment: .leading, spacing: 16) {
                    Text("About")
                        .font(.headline)
                    Text("Bob the Builder is a comprehensive construction management application designed to streamline project coordination, RFI tracking, and team collaboration.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                // Features
                VStack(alignment: .leading, spacing: 16) {
                    Text("Features")
                        .font(.headline)
                    FeatureRow(icon: "hammer.fill", title: "Project Management", description: "Track and manage construction projects")
                    FeatureRow(icon: "doc.text.fill", title: "RFI Tracking", description: "Submit and respond to RFIs efficiently")
                    FeatureRow(icon: "person.3.fill", title: "Team Collaboration", description: "Work together with your team in real-time")
                    FeatureRow(icon: "icloud.fill", title: "Cloud Sync", description: "Access your data from anywhere")
                }
                .padding(.horizontal)

                // Legal
                VStack(spacing: 12) {
                    Link(destination: URL(string: "https://www.example.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }

                    Link(destination: URL(string: "https://www.example.com/terms")!) {
                        HStack {
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }

                    Link(destination: URL(string: "https://www.example.com/licenses")!) {
                        HStack {
                            Text("Open Source Licenses")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                // Copyright
                VStack(spacing: 8) {
                    Text("© 2024 Bob the Builder Project")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("All rights reserved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AboutPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutPlaceholder()
        }
    }
}
