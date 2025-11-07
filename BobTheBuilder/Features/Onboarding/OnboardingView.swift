//
//  OnboardingView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var coordinator = AppCoordinator.shared
    @State private var currentPage = 0

    private let pages = [
        OnboardingPage(
            icon: "hammer.circle.fill",
            title: "Welcome to Bob the Builder",
            description: "Your complete construction management solution for tracking projects, RFIs, and team collaboration.",
            iconColor: .blue
        ),
        OnboardingPage(
            icon: "building.2.fill",
            title: "Manage Projects",
            description: "Keep track of all your construction projects in one place with real-time updates and status tracking.",
            iconColor: .green
        ),
        OnboardingPage(
            icon: "doc.text.fill",
            title: "Track RFIs",
            description: "Submit and respond to Requests for Information quickly and efficiently with your team.",
            iconColor: .orange
        ),
        OnboardingPage(
            icon: "person.3.fill",
            title: "Collaborate with Your Team",
            description: "Work together seamlessly with cloud sync and real-time notifications across all your devices.",
            iconColor: .purple
        )
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    Button("Skip") {
                        coordinator.completeOnboarding()
                    }
                    .font(.subheadline)
                    .padding()
                }
                .opacity(currentPage < pages.count - 1 ? 1 : 0)

                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                // Bottom Button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        coordinator.completeOnboarding()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let iconColor: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(page.iconColor)

            // Title
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Description
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
