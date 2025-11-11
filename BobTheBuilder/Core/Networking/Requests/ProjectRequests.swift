//
//  ProjectRequests.swift
//  BobTheBuilder
//
//  Created on November 9, 2025.
//

import Foundation

// MARK: - Get Projects Request

struct GetProjectsRequest: APIRequest {
    typealias Response = [Project]

    var path: String { "/projects" }
    var method: HTTPMethod { .get }
    var parameters: [String: Any]? {
        var params: [String: Any] = [:]

        if let organizationId = organizationId {
            params["organizationId"] = organizationId
        }
        if let status = status {
            params["status"] = status
        }
        params["myProjects"] = myProjects

        return params.isEmpty ? nil : params
    }

    let organizationId: String?
    let status: String?
    let myProjects: Bool

    init(organizationId: String? = nil, status: String? = nil, myProjects: Bool = true) {
        self.organizationId = organizationId
        self.status = status
        self.myProjects = myProjects
    }
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
    let status: ProjectStatus?
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
