//
//  EnvironmentBadge.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct EnvironmentBadge: View {
    let configuration = AppConfiguration.shared

    var body: some View {
        if configuration.environment != .production {
            HStack {
                Text(configuration.environment.displayName)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(configuration.environment.themeColor)
                    .cornerRadius(4)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
}

struct EnvironmentBadge_Previews: PreviewProvider {
    static var previews: some View {
        EnvironmentBadge()
    }
}
