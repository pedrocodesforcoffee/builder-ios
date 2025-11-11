//
//  PermissionModifiers.swift
//  BobTheBuilder
//
//  SwiftUI View Modifiers for Permission-Based UI
//

import SwiftUI

// MARK: - Permission Guard

extension View {
    /// Show/hide view based on permission
    func permissionGuard(_ permission: String) -> some View {
        modifier(PermissionGuardModifier(permission: permission))
    }

    /// Show/hide view based on any permission
    func permissionGuardAny(_ permissions: [String]) -> some View {
        modifier(PermissionGuardAnyModifier(permissions: permissions))
    }

    /// Show/hide view based on all permissions
    func permissionGuardAll(_ permissions: [String]) -> some View {
        modifier(PermissionGuardAllModifier(permissions: permissions))
    }

    /// Show/hide view based on role
    func roleGuard(_ role: ProjectRole) -> some View {
        modifier(RoleGuardModifier(role: role))
    }

    /// Show/hide view based on any role
    func roleGuardAny(_ roles: [ProjectRole]) -> some View {
        modifier(RoleGuardAnyModifier(roles: roles))
    }

    /// Disable view without permission (with optional alert)
    func requirePermission(
        _ permission: String,
        message: String? = nil
    ) -> some View {
        modifier(RequirePermissionModifier(permission: permission, message: message))
    }

    /// Disable view without any of the permissions
    func requireAnyPermission(
        _ permissions: [String],
        message: String? = nil
    ) -> some View {
        modifier(RequireAnyPermissionModifier(permissions: permissions, message: message))
    }
}

// MARK: - Permission Guard Modifier

struct PermissionGuardModifier: ViewModifier {
    let permission: String
    @EnvironmentObject var permissionService: PermissionService

    func body(content: Content) -> some View {
        if permissionService.hasPermission(permission) {
            content
        }
    }
}

struct PermissionGuardAnyModifier: ViewModifier {
    let permissions: [String]
    @EnvironmentObject var permissionService: PermissionService

    func body(content: Content) -> some View {
        if permissionService.hasAnyPermission(permissions) {
            content
        }
    }
}

struct PermissionGuardAllModifier: ViewModifier {
    let permissions: [String]
    @EnvironmentObject var permissionService: PermissionService

    func body(content: Content) -> some View {
        if permissionService.hasAllPermissions(permissions) {
            content
        }
    }
}

// MARK: - Role Guard Modifier

struct RoleGuardModifier: ViewModifier {
    let role: ProjectRole
    @EnvironmentObject var permissionService: PermissionService

    func body(content: Content) -> some View {
        if permissionService.hasRole(role) {
            content
        }
    }
}

struct RoleGuardAnyModifier: ViewModifier {
    let roles: [ProjectRole]
    @EnvironmentObject var permissionService: PermissionService

    func body(content: Content) -> some View {
        if permissionService.hasAnyRole(roles) {
            content
        }
    }
}

// MARK: - Require Permission Modifier

struct RequirePermissionModifier: ViewModifier {
    let permission: String
    let message: String?

    @EnvironmentObject var permissionService: PermissionService
    @State private var showAlert = false

    func body(content: Content) -> some View {
        let hasPermission = permissionService.hasPermission(permission)

        content
            .disabled(!hasPermission)
            .opacity(hasPermission ? 1.0 : 0.5)
            .overlay(
                Group {
                    if !hasPermission && message != nil {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showAlert = true
                            }
                    }
                }
            )
            .alert("Permission Required", isPresented: $showAlert) {
                Button("OK") { showAlert = false }
            } message: {
                Text(message ?? "You do not have permission to perform this action")
            }
    }
}

struct RequireAnyPermissionModifier: ViewModifier {
    let permissions: [String]
    let message: String?

    @EnvironmentObject var permissionService: PermissionService
    @State private var showAlert = false

    func body(content: Content) -> some View {
        let hasPermission = permissionService.hasAnyPermission(permissions)

        content
            .disabled(!hasPermission)
            .opacity(hasPermission ? 1.0 : 0.5)
            .overlay(
                Group {
                    if !hasPermission && message != nil {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showAlert = true
                            }
                    }
                }
            )
            .alert("Permission Required", isPresented: $showAlert) {
                Button("OK") { showAlert = false }
            } message: {
                Text(message ?? "You do not have permission to perform this action")
            }
    }
}

// MARK: - Role-Based Rendering

struct RoleBasedView<Content: View>: View {
    let content: (ProjectRole) -> Content
    @EnvironmentObject var permissionService: PermissionService

    var body: some View {
        if let role = permissionService.userRole {
            content(role)
        }
    }
}

// MARK: - Conditional Role Content

struct ConditionalRoleContent<TrueContent: View, FalseContent: View>: View {
    let role: ProjectRole
    let trueContent: () -> TrueContent
    let falseContent: () -> FalseContent

    @EnvironmentObject var permissionService: PermissionService

    var body: some View {
        if permissionService.hasRole(role) {
            trueContent()
        } else {
            falseContent()
        }
    }
}
