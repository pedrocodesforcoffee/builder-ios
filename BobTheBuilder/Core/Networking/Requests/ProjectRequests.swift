//
//  ProjectRequests.swift
//  BobTheBuilder
//
//  Created on November 9, 2025.
//

import Foundation

// MARK: - Get Projects Request

struct GetProjectsRequest: APIRequest {
    typealias Response = ProjectsResponse

    var path: String { "/projects" }
    var method: HTTPMethod { .get }
    var parameters: [String: Any]? {
        return [
            "page": page,
            "limit": limit
        ]
    }

    let page: Int
    let limit: Int

    init(page: Int = 1, limit: Int = 20) {
        self.page = page
        self.limit = limit
    }
}

struct ProjectsResponse: Codable {
    let projects: [Project]
    let total: Int
    let page: Int
    let totalPages: Int
}

// MARK: - Get Project Detail Request

struct GetProjectDetailRequest: APIRequest {
    typealias Response = Project

    let projectId: String

    var path: String { "/projects/\(projectId)" }
    var method: HTTPMethod { .get }
}

// MARK: - Create Project Request

struct CreateProjectRequest: APIRequest {
    typealias Response = Project

    let name: String
    let description: String?
    let location: String?
    let dueDate: Date?

    var path: String { "/projects" }
    var method: HTTPMethod { .post }
    var body: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(CreateProjectData(
            name: name,
            description: description,
            location: location,
            dueDate: dueDate
        ))
    }
}

private struct CreateProjectData: Codable {
    let name: String
    let description: String?
    let location: String?
    let dueDate: Date?
}

// MARK: - Update Project Request

struct UpdateProjectRequest: APIRequest {
    typealias Response = Project

    let projectId: String
    let name: String?
    let description: String?
    let location: String?
    let status: Project.ProjectStatus?
    let progress: Double?

    var path: String { "/projects/\(projectId)" }
    var method: HTTPMethod { .put }
    var body: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(UpdateProjectData(
            name: name,
            description: description,
            location: location,
            status: status?.rawValue,
            progress: progress
        ))
    }
}

private struct UpdateProjectData: Codable {
    let name: String?
    let description: String?
    let location: String?
    let status: String?
    let progress: Double?
}

// MARK: - Delete Project Request

struct DeleteProjectRequest: APIRequest {
    typealias Response = EmptyResponse

    let projectId: String

    var path: String { "/projects/\(projectId)" }
    var method: HTTPMethod { .delete }
}
