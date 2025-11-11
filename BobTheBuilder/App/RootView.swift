//
//  RootView.swift
//  BobTheBuilder
//
//  Created on November 9, 2025.
//

import SwiftUI

struct RootView: View {
    @StateObject private var coordinator = AppCoordinator.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var navigationManager = NavigationPathManager.shared

    @State private var showingSplash = true
    @State private var pendingDeepLink: URL?

    var body: some View {
        ZStack {
            if showingSplash {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                mainContent
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingSplash)
        .animation(.easeInOut(duration: 0.3), value: coordinator.isAuthenticated)
        .onAppear {
            startApp()
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
        .alert(item: $coordinator.appError) { error in
            Alert(
                title: Text(error.title),
                message: Text(error.message),
                dismissButton: .default(Text("OK")) {
                    error.dismissAction?()
                }
            )
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if coordinator.isLoading {
            LoadingView()
        } else if coordinator.showOnboarding {
            OnboardingView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
        } else if !coordinator.isAuthenticated {
            authenticationView
                .transition(.asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .move(edge: .trailing)
                ))
        } else {
            MainTabView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .onAppear {
                    processPendingDeepLink()
                }
        }
    }

    private var authenticationView: some View {
        NavigationView {
            LoginView()
        }
        .navigationViewStyle(.stack)
        .environmentObject(authManager)
    }

    private func startApp() {
        Task {
            // Initialize auth state
            authManager.checkAuthenticationStatus()

            // Small delay for splash screen
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

            await MainActor.run {
                showingSplash = false
            }
        }
    }

    private func handleDeepLink(_ url: URL) {
        if coordinator.isAuthenticated {
            coordinator.handleDeepLink(url)
        } else {
            // Store for after authentication
            pendingDeepLink = url
            UserDefaults.standard.set(url.absoluteString, forKey: "pendingDeepLink")
        }
    }

    private func processPendingDeepLink() {
        // Check for pending deep link
        if let url = pendingDeepLink {
            pendingDeepLink = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                coordinator.handleDeepLink(url)
            }
        } else if let urlString = UserDefaults.standard.string(forKey: "pendingDeepLink"),
                  let url = URL(string: urlString) {
            UserDefaults.standard.removeObject(forKey: "pendingDeepLink")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                coordinator.handleDeepLink(url)
            }
        }
    }
}
