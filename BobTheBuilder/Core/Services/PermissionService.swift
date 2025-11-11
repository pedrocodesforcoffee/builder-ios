//
//  PermissionService.swift
//  BobTheBuilder
//
//  Permission management service with caching support
//

import Foundation
import Combine

@MainActor
final class PermissionService: ObservableObject {
    static let shared = PermissionService()

    @Published var permissions: [String: Bool] = [:]
    @Published var userRole: ProjectRole?
    @Published var scope: UserScope?
    @Published var expiresAt: Date?
    @Published var isLoading = false
    @Published var error: Error?

    private let apiClient: APIClientProtocol
    private let cacheService: PermissionCacheService
    private var currentProjectId: String?

    init(
        apiClient: APIClientProtocol = APIClient.shared,
        cacheService: PermissionCacheService = PermissionCacheService.shared
    ) {
        self.apiClient = apiClient
        self.cacheService = cacheService
    }

    /// Fetch permissions for a project
    func fetchPermissions(projectId: String) async {
        currentProjectId = projectId
        isLoading = true
        error = nil

        do {
            // Try to load from cache first (for offline support)
            if let cached = try? cacheService.getCachedPermissions(projectId: projectId),
               !cached.isStale {
                self.permissions = cached.permissions
                self.userRole = cached.role
                self.scope = cached.scope
                self.expiresAt = cached.expiresAt
                print("📋 Loaded permissions from cache for project: \(projectId)")
            }

            // Fetch fresh data from API
            let request = GetPermissionsRequest(projectId: projectId)
            let response = try await apiClient.execute(request)

            // Update state
            self.permissions = response.permissions
            self.userRole = response.role
            self.scope = response.scope
            self.expiresAt = response.expiresAt

            // Cache the result
            cacheService.cachePermissions(
                projectId: projectId,
                permissions: response.permissions,
                role: response.role,
                scope: response.scope,
                expiresAt: response.expiresAt
            )

            print("✅ Fetched fresh permissions for project: \(projectId)")
            isLoading = false

        } catch {
            self.error = error
            isLoading = false
            print("❌ Failed to fetch permissions: \(error.localizedDescription)")

            // If we have cached data, use it despite the error
            if let cached = try? cacheService.getCachedPermissions(projectId: projectId) {
                self.permissions = cached.permissions
                self.userRole = cached.role
                self.scope = cached.scope
                self.expiresAt = cached.expiresAt
                print("⚠️ Using stale cached permissions due to network error")
            }
        }
    }

    // MARK: - Permission Checking

    /// Check if user has a specific permission
    func hasPermission(_ permission: String) -> Bool {
        return permissions[permission] == true
    }

    /// Check if user has any of the permissions
    func hasAnyPermission(_ permissions: [String]) -> Bool {
        return permissions.contains { hasPermission($0) }
    }

    /// Check if user has all permissions
    func hasAllPermissions(_ permissions: [String]) -> Bool {
        return permissions.allSatisfy { hasPermission($0) }
    }

    /// Check if user has a specific role
    func hasRole(_ role: ProjectRole) -> Bool {
        return userRole == role
    }

    /// Check if user has any of the roles
    func hasAnyRole(_ roles: [ProjectRole]) -> Bool {
        guard let userRole = userRole else { return false }
        return roles.contains(userRole)
    }

    // MARK: - Expiration

    /// Check if user's access is expired
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }

    /// Check if access is expiring soon (within threshold days)
    func isExpiringSoon(threshold: Int = 7) -> Bool {
        guard let days = daysUntilExpiration else { return false }
        return days > 0 && days <= threshold
    }

    /// Days remaining until expiration
    var daysUntilExpiration: Int? {
        guard let expiresAt = expiresAt else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day
        return days
    }

    // MARK: - Scope

    /// Check if user has scope limitations
    var hasScope: Bool {
        guard let scope = scope else { return false }
        return !scope.isEmpty
    }

    /// Check if an item is in user's scope
    func isInScope(itemId: String, type: ScopeType) -> Bool {
        guard let scope = scope else { return true } // No scope = full access
        return scope.isInScope(itemId: itemId, type: type)
    }

    /// Filter items by scope
    func filterByScope<T: Identifiable>(
        _ items: [T],
        scopeField: (T) -> String?,
        scopeType: ScopeType
    ) -> [T] {
        guard let scope = scope, !scope.isEmpty else {
            return items // No scope = return all
        }

        return items.filter { item in
            guard let scopeValue = scopeField(item) else { return true }
            return scope.isInScope(itemId: scopeValue, type: scopeType)
        }
    }

    // MARK: - Cache Management

    /// Clear cached permissions for current project
    func clearCache() {
        guard let projectId = currentProjectId else { return }
        cacheService.clearCache(projectId: projectId)
    }

    /// Clear all cached permissions
    func clearAllCaches() {
        cacheService.clearAllCaches()
    }

    /// Reset permission state
    func reset() {
        permissions = [:]
        userRole = nil
        scope = nil
        expiresAt = nil
        error = nil
        currentProjectId = nil
    }
}

// MARK: - API Request

struct GetPermissionsRequest: APIRequest {
    typealias Response = PermissionResponse

    let projectId: String

    var path: String {
        "/projects/\(projectId)/my-permissions"
    }

    var method: HTTPMethod {
        .get
    }

    var requiresAuth: Bool {
        true
    }
}
