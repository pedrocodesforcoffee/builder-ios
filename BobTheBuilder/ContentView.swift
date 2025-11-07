//
//  ContentView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    // Get app version from Bundle
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding()

                Text("Bob the Builder")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Version \(appVersion) (\(buildNumber))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Environment: TBD")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 40)

                Spacer()
            }
            .padding()
            .navigationTitle("Bob the Builder")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
