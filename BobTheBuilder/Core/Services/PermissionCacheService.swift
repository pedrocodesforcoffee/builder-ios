//
//  PermissionCacheService.swift
//  BobTheBuilder
//
//  Caching service for permission data
//

import Foundation

final class PermissionCacheService {
    static let shared = PermissionCacheService()

    private let userDefaults = UserDefaults.standard
    private let cacheKeyPrefix = "permissions_cache_"

    private init() {}

    // MARK: - Cache Operations

    /// Cache permissions for a project
    func cachePermissions(
        projectId: String,
        permissions: [String: Bool],
        role: ProjectRole,
        scope: UserScope?,
        expiresAt: Date?
    ) {
        let cached = CachedPermissions(
            permissions: permissions,
            role: role,
            scope: scope,
            expiresAt: expiresAt,
            cachedAt: Date()
        )

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(cached)
            userDefaults.set(data, forKey: cacheKey(for: projectId))
            print("💾 Cached permissions for project: \(projectId)")
        } catch {
            print("❌ Failed to cache permissions: \(error)")
        }
    }

    /// Get cached permissions for a project
    func getCachedPermissions(projectId: String) throws -> CachedPermissions? {
        guard let data = userDefaults.data(forKey: cacheKey(for: projectId)) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(CachedPermissions.self, from: data)
    }

    /// Clear cache for a specific project
    func clearCache(projectId: String) {
        userDefaults.removeObject(forKey: cacheKey(for: projectId))
        print("🗑️ Cleared permission cache for project: \(projectId)")
    }

    /// Clear all permission caches
    func clearAllCaches() {
        let keys = userDefaults.dictionaryRepresentation().keys
        for key in keys where key.hasPrefix(cacheKeyPrefix) {
            userDefaults.removeObject(forKey: key)
        }
        print("🗑️ Cleared all permission caches")
    }

    // MARK: - Private Helpers

    private func cacheKey(for projectId: String) -> String {
        return "\(cacheKeyPrefix)\(projectId)"
    }
}
