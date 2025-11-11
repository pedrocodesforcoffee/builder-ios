//
//  OrganizationsSection.swift
//  BobTheBuilder
//
//  Dashboard organizations section component
//  Created on November 10, 2025.
//

import SwiftUI

struct OrganizationsSection: View {
    let organizations: [Organization]
    @StateObject private var navigationManager = NavigationPathManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Text("Organizations")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                // TODO: Add "See All" button when organizations list view is implemented
                // if !organizations.isEmpty {
                //     Button(action: {
                //         // Navigate to organizations list
                //         navigationManager.navigate(to: .organizations)
                //     }) {
                //         Text("See All")
                //             .font(.subheadline)
                //             .foregroundColor(.blue)
                //     }
                // }
            }
            .padding(.horizontal)

            if organizations.isEmpty {
                EmptyOrganizationsView()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(organizations.prefix(5)) { organization in
                            OrganizationCard(organization: organization)
                                .onTapGesture {
                                    // Navigate to organization detail
                                    // TODO: Implement organization detail navigation
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct OrganizationCard: View {
    let organization: Organization

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon/logo
            HStack {
                if let logoURL = organization.logo, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .empty, .failure, _:
                            initialsView
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    initialsView
                }

                Spacer()

                Image(systemName: organization.typeIcon)
                    .font(.caption)
                    .foregroundColor(organization.typeColor)
            }

            // Organization Name
            VStack(alignment: .leading, spacing: 4) {
                Text(organization.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(organization.formattedType)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Statistics
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(organization.memberCount ?? 0)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Members")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(organization.projectCount ?? 0)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Projects")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Active Status
            if organization.isActive {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Active")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }

    private var initialsView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(organization.typeColor.opacity(0.2))
                .frame(width: 40, height: 40)

            Text(organization.initials)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(organization.typeColor)
        }
    }
}

struct EmptyOrganizationsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "building.2")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))

            Text("No Organizations")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("You're not part of any organizations yet")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct OrganizationsSection_Previews: PreviewProvider {
    static var previews: some View {
        OrganizationsSection(
            organizations: [
                Organization(
                    id: "1",
                    name: "Acme Construction",
                    slug: "acme-construction",
                    type: "GENERAL_CONTRACTOR",
                    logo: nil,
                    description: "Leading construction company",
                    isActive: true,
                    createdAt: "2024-01-01T00:00:00Z",
                    updatedAt: nil,
                    memberCount: 25,
                    projectCount: 10
                ),
                Organization(
                    id: "2",
                    name: "Smith Engineering",
                    slug: "smith-engineering",
                    type: "ENGINEER",
                    logo: nil,
                    description: "Engineering firm",
                    isActive: true,
                    createdAt: "2024-01-01T00:00:00Z",
                    updatedAt: nil,
                    memberCount: 15,
                    projectCount: 8
                )
            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
