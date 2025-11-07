//
//  BobTheBuilderApp.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

@main
struct BobTheBuilderApp: App {
    @StateObject private var coordinator = AppCoordinator.shared

    init() {
        setupApp()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if coordinator.isLoading {
                    LoadingView()
                } else if coordinator.showOnboarding {
                    OnboardingView()
                } else if !coordinator.isAuthenticated {
                    LoginView()
                } else {
                    MainTabView()
                }
            }
            .onOpenURL { url in
                coordinator.handleDeepLink(url)
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
    }

    // MARK: - Private Methods

    private func setupApp() {
        // Configure app-wide settings
        configureAppearance()
    }

    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}
