//
//  MainTabView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var navigationManager = NavigationPathManager.shared
    @StateObject private var coordinator = AppCoordinator.shared

    var body: some View {
        TabView(selection: $navigationManager.selectedTab) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                NavigationView {
                    rootView(for: tab)
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label(tab.title, systemImage: tab.systemImage)
                }
                .tag(tab)
            }
        }
    }

    @ViewBuilder
    private func rootView(for tab: TabItem) -> some View {
        switch tab {
        case .projects:
            ProjectListView()
        case .rfis:
            RFIListView()
        case .settings:
            SettingsView()
        }
    }

    // Note: For iOS 15, navigation to detail views will be handled via NavigationLink
    // in the individual list views rather than through a centralized destination handler
    //
    // @ViewBuilder
    // private func destinationView(for destination: NavigationDestination) -> some View {
    //     switch destination {
    //     case .projectDetail(let projectId):
    //         ProjectDetailPlaceholder(projectId: projectId)
    //     case .rfiDetail(let rfiId):
    //         RFIDetailPlaceholder(rfiId: rfiId)
    //     case .createProject:
    //         // Will be presented as sheet
    //         EmptyView()
    //     case .createRFI(let projectId):
    //         // Will be presented as sheet
    //         EmptyView()
    //     case .profile:
    //         ProfilePlaceholder()
    //     case .settings:
    //         SettingsView()
    //     case .about:
    //         AboutPlaceholder()
    //     }
    // }

}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
