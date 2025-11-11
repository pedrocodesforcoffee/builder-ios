//
//  SplashScreenView.swift
//  BobTheBuilder
//
//  Created on November 9, 2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.blue.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Logo
                Image(systemName: "hammer.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(isAnimating ? 0 : -10))
                    .scaleEffect(scale)
                    .opacity(opacity)

                // App name
                Text("Bob the Builder")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .opacity(opacity)

                // Tagline
                Text("Build Better Together")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .opacity(opacity * 0.8)

                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.2)
                    .padding(.top, 20)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.0
                opacity = 1.0
                isAnimating = true
            }
        }
    }
}
