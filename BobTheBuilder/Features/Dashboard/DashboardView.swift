//
//  DashboardView.swift
//  BobTheBuilder
//
//  Main dashboard view displaying project overview and statistics
//  Created on November 10, 2025.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var dashboardService = DashboardService.shared
    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        ProtectedView(requiresAuth: true) {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    WelcomeHeaderView()
                        .padding(.top, 8)

                    if dashboardService.isLoading && dashboardService.organizations.isEmpty {
                        // Initial loading state
                        loadingView
                    } else if let error = dashboardService.error {
                        // Error state with retry
                        errorView(error: error)
                    } else {
                        // Content
                        dashboardContent
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await refreshData()
            }
            .onAppear {
                loadInitialData()
            }
        }
    }

    private var dashboardContent: some View {
        VStack(spacing: 20) {
            // Statistics Cards
            StatisticsCardsView(
                projectStats: dashboardService.projectStatistics,
                organizationStats: dashboardService.organizationStatistics
            )

            // Organizations Section
            if !dashboardService.organizations.isEmpty {
                OrganizationsSection(organizations: dashboardService.organizations)
            }

            // Quick Actions
            QuickActionsSection()

            // Recent Projects
            if !dashboardService.projects.isEmpty {
                RecentProjectsSection(projects: dashboardService.recentProjects)
            }

            // Recent Activity
            if !dashboardService.activities.isEmpty {
                RecentActivitySection(activities: dashboardService.recentActivities)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading dashboard...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }

    private func errorView(error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Unable to Load Dashboard")
                .font(.title3)
                .fontWeight(.semibold)

            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                Task {
                    await refreshData()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    private func loadInitialData() {
        // Only load if we don't have data yet
        guard dashboardService.organizations.isEmpty &&
              dashboardService.projects.isEmpty &&
              dashboardService.activities.isEmpty &&
              !dashboardService.isLoading else {
            return
        }

        Task {
            await dashboardService.fetchDashboardData()
        }
    }

    private func refreshData() async {
        await dashboardService.fetchDashboardData()
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
        }
    }
}
