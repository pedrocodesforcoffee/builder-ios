//
//  ContentView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let configuration = AppConfiguration.shared

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                EnvironmentBadge()

                Spacer()

                Image(systemName: "hammer.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding()

                Text("Bob the Builder")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 10) {
                    Label("Environment: \(configuration.environment.rawValue)", systemImage: "server.rack")
                    Label("API: \(configuration.apiBaseURL)", systemImage: "network")
                    Label("Version: \(configuration.appVersion) (\(configuration.buildNumber))", systemImage: "info.circle")
                    if configuration.isDebugBuild {
                        Label("Debug Build", systemImage: "ant.fill")
                            .foregroundColor(.orange)
                    }
                }
                .font(.footnote)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationTitle(configuration.appName)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
