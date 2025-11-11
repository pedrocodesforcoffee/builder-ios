//
//  ProjectMembersViewModel.swift
//  BobTheBuilder
//
//  View model for project members list
//

import Foundation
import Combine

@MainActor
final class ProjectMembersViewModel: ObservableObject {
    @Published var members: [ProjectMember] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let projectId: String
    private let apiClient: APIClientProtocol

    init(projectId: String, apiClient: APIClientProtocol = APIClient.shared) {
        self.projectId = projectId
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    func loadMembers() async {
        isLoading = true
        error = nil

        do {
            let request = GetProjectMembersRequest(projectId: projectId)
            let response = try await apiClient.execute(request)
            self.members = response.members
            isLoading = false
            print("✅ Loaded \(members.count) members for project: \(projectId)")
        } catch {
            self.error = error
            isLoading = false
            print("❌ Failed to load members: \(error.localizedDescription)")
        }
    }

    func refresh() async {
        await loadMembers()
    }

    func removeMember(_ member: ProjectMember) async {
        do {
            let request = RemoveMemberRequest(projectId: projectId, userId: member.user.id)
            _ = try await apiClient.execute(request)

            // Remove from local list
            members.removeAll { $0.id == member.id }
            print("✅ Removed member: \(member.user.name)")
        } catch {
            self.error = error
            print("❌ Failed to remove member: \(error.localizedDescription)")
        }
    }
}

// MARK: - API Requests

struct GetProjectMembersRequest: APIRequest {
    typealias Response = ProjectMembersResponse

    let projectId: String

    var path: String {
        "/projects/\(projectId)/members"
    }

    var method: HTTPMethod {
        .get
    }

    var requiresAuth: Bool {
        true
    }
}

struct RemoveMemberRequest: APIRequest {
    typealias Response = EmptyResponse

    let projectId: String
    let userId: String

    var path: String {
        "/projects/\(projectId)/members/\(userId)"
    }

    var method: HTTPMethod {
        .delete
    }

    var requiresAuth: Bool {
        true
    }
}

// MARK: - Response Types

struct ProjectMembersResponse: Codable {
    let members: [ProjectMember]
}
