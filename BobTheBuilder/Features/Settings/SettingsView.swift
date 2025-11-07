//
//  SettingsView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var navigationManager = NavigationPathManager.shared
    @StateObject private var coordinator = AppCoordinator.shared
    @State private var notificationsEnabled = true
    @State private var biometricsEnabled = false
    @State private var offlineModeEnabled = false

    var body: some View {
        List {
            // Profile Section
            Section {
                Button(action: {
                    navigationManager.navigate(to: .profile)
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("John Doe")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("john.doe@example.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }

            // Preferences Section
            Section("Preferences") {
                Toggle("Push Notifications", isOn: $notificationsEnabled)
                Toggle("Biometric Authentication", isOn: $biometricsEnabled)
                Toggle("Offline Mode", isOn: $offlineModeEnabled)
            }

            // App Information Section
            Section("App Information") {
                SettingsRow(
                    icon: "info.circle",
                    title: "About",
                    iconColor: .blue
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    navigationManager.navigate(to: .about)
                }

                SettingsRow(
                    icon: "doc.text",
                    title: "Privacy Policy",
                    iconColor: .green
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    // Future: Open privacy policy
                }

                SettingsRow(
                    icon: "doc.plaintext",
                    title: "Terms of Service",
                    iconColor: .orange
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    // Future: Open terms of service
                }

                HStack {
                    SettingsRow(
                        icon: "number",
                        title: "Version",
                        iconColor: .gray
                    )
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                }
            }

            // Environment Section (Debug/Dev only)
            if AppConfiguration.shared.environment != .production {
                Section("Development") {
                    HStack {
                        SettingsRow(
                            icon: "gearshape.2",
                            title: "Environment",
                            iconColor: .purple
                        )
                        Spacer()
                        Text(AppConfiguration.shared.environment.displayName)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        SettingsRow(
                            icon: "network",
                            title: "API Base URL",
                            iconColor: .purple
                        )
                        Spacer()
                        Text(apiBaseHost)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            // Account Section
            Section {
                Button(action: {
                    coordinator.logout()
                }) {
                    HStack {
                        SettingsRow(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Sign Out",
                            iconColor: .red
                        )
                    }
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var apiBaseHost: String {
        guard let url = URL(string: AppConfiguration.shared.apiBaseURL) else {
            return AppConfiguration.shared.apiBaseURL
        }
        return url.host ?? AppConfiguration.shared.apiBaseURL
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(iconColor)
                .frame(width: 24)
            Text(title)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
