//
//  LoadingView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // App Logo/Icon
                Image(systemName: "hammer.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                // App Name
                Text("Bob the Builder")
                    .font(.title)
                    .fontWeight(.bold)

                // Progress Indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding(.top, 8)

                // Loading Text
                Text("Loading...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
