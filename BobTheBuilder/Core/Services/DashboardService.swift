//
//  DashboardService.swift
//  BobTheBuilder
//
//  Dashboard data aggregation service
//  Created on November 10, 2025.
//

import Foundation
import Combine

@MainActor
final class DashboardService: ObservableObject {
    static let shared = DashboardService()

    // Published state
    @Published var organizations: [Organization] = []
    @Published var projects: [Project] = []
    @Published var activities: [Activity] = []
    @Published var isLoading = false
    @Published var error: Error?

    // Loading states for individual sections
    @Published var isLoadingOrganizations = false
    @Published var isLoadingProjects = false
    @Published var isLoadingActivities = false

    private let apiClient: APIClientProtocol
    private var cancellables = Set<AnyCancellable>()

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    // MARK: - Dashboard Data Fetching

    /// Fetch all dashboard data (organizations, projects, activities)
    func fetchDashboardData() async {
        isLoading = true
        error = nil

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchOrganizations() }
            group.addTask { await self.fetchProjects() }
            // Activities endpoint not yet implemented in backend
            // group.addTask { await self.fetchActivities() }
        }

        isLoading = false
    }

    /// Fetch organizations
    func fetchOrganizations() async {
        isLoadingOrganizations = true

        do {
            let request = GetOrganizationsRequest()
            let organizations = try await apiClient.execute(request)
            self.organizations = organizations
            print("✅ Fetched \(organizations.count) organizations")
        } catch {
            self.error = error
            print("❌ Failed to fetch organizations: \(error.localizedDescription)")
        }

        isLoadingOrganizations = false
    }

    /// Fetch projects with optional filters
    func fetchProjects(status: String? = nil, limit: Int = 10) async {
        isLoadingProjects = true

        do {
            let request = DashboardGetProjectsRequest(status: status)
            let projects = try await apiClient.execute(request)
            // Limit results client-side since API doesn't support limit parameter
            self.projects = Array(projects.prefix(limit))
            print("✅ Fetched \(self.projects.count) projects")
        } catch {
            self.error = error
            print("❌ Failed to fetch projects: \(error.localizedDescription)")
        }

        isLoadingProjects = false
    }

    /// Fetch recent activities
    func fetchActivities(limit: Int = 20) async {
        isLoadingActivities = true

        do {
            let request = GetActivitiesRequest(limit: limit)
            let response = try await apiClient.execute(request)
            self.activities = response.data
            print("✅ Fetched \(response.data.count) activities")
        } catch {
            self.error = error
            print("❌ Failed to fetch activities: \(error.localizedDescription)")
        }

        isLoadingActivities = false
    }

    // MARK: - Statistics

    /// Get project statistics
    var projectStatistics: ProjectStatistics {
        let activeProjects = projects.filter { $0.statusEnum == .active }.count
        let totalProjects = projects.count
        let completedProjects = projects.filter { $0.statusEnum == .completed }.count
        let onHoldProjects = projects.filter { $0.statusEnum == .onHold }.count

        return ProjectStatistics(
            total: totalProjects,
            active: activeProjects,
            completed: completedProjects,
            onHold: onHoldProjects
        )
    }

    /// Get organization statistics
    var organizationStatistics: OrganizationStatistics {
        let activeOrgs = organizations.filter { $0.isActive }.count
        let totalMembers = organizations.reduce(0) { $0 + ($1.memberCount ?? 0) }
        let totalOrgProjects = organizations.reduce(0) { $0 + ($1.projectCount ?? 0) }

        return OrganizationStatistics(
            total: organizations.count,
            active: activeOrgs,
            totalMembers: totalMembers,
            totalProjects: totalOrgProjects
        )
    }

    // MARK: - Filtered Data

    /// Get active projects
    var activeProjects: [Project] {
        projects.filter { $0.statusEnum == .active }
    }

    /// Get recent projects (sorted by creation date)
    var recentProjects: [Project] {
        projects.sorted { p1, p2 in
            guard let date1 = p1.createdAt.toDate(),
                  let date2 = p2.createdAt.toDate() else {
                return false
            }
            return date1 > date2
        }
    }

    /// Get overdue projects
    var overdueProjects: [Project] {
        projects.filter { $0.isOverdue }
    }

    /// Get active organizations
    var activeOrganizations: [Organization] {
        organizations.filter { $0.isActive }
    }

    /// Get recent activities (already sorted by backend)
    var recentActivities: [Activity] {
        activities
    }

    // MARK: - Reset

    /// Reset all dashboard state
    func reset() {
        organizations = []
        projects = []
        activities = []
        error = nil
        isLoading = false
        isLoadingOrganizations = false
        isLoadingProjects = false
        isLoadingActivities = false
    }
}

// MARK: - Statistics Models

struct ProjectStatistics {
    let total: Int
    let active: Int
    let completed: Int
    let onHold: Int
}

struct OrganizationStatistics {
    let total: Int
    let active: Int
    let totalMembers: Int
    let totalProjects: Int
}

// MARK: - API Requests

struct GetOrganizationsRequest: APIRequest {
    typealias Response = [Organization]

    var path: String {
        "/organizations"
    }

    var method: HTTPMethod {
        .get
    }
}

struct DashboardGetProjectsRequest: APIRequest {
    typealias Response = [Project]

    let status: String?

    var path: String {
        "/projects"
    }

    var method: HTTPMethod {
        .get
    }

    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        if let status = status {
            params["status"] = status
        }
        return params.isEmpty ? nil : params
    }
}

struct GetActivitiesRequest: APIRequest {
    typealias Response = ActivityListResponse

    let limit: Int

    var path: String {
        "/activities"
    }

    var method: HTTPMethod {
        .get
    }

    var parameters: [String: Any]? {
        ["limit": limit]
    }
}

// MARK: - API Response Models

struct OrganizationListResponse: Codable {
    let data: [Organization]
    let total: Int?
    let page: Int?
    let limit: Int?
}

struct ProjectListResponse: Codable {
    let data: [Project]
    let total: Int?
    let page: Int?
    let limit: Int?
}

struct ActivityListResponse: Codable {
    let data: [Activity]
    let total: Int?
    let page: Int?
    let limit: Int?
}
