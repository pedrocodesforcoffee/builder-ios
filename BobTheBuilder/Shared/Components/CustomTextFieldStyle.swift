//
//  CustomTextFieldStyle.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    let systemImage: String

    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.gray)
                .frame(width: 20)

            configuration
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Previews

struct CustomTextFieldStyle_Previews: PreviewProvider {
    @State static var text = ""

    static var previews: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $text)
                .textFieldStyle(CustomTextFieldStyle(systemImage: "envelope"))

            SecureField("Password", text: $text)
                .textFieldStyle(CustomTextFieldStyle(systemImage: "lock"))

            TextField("Search", text: $text)
                .textFieldStyle(CustomTextFieldStyle(systemImage: "magnifyingglass"))
        }
        .padding()
    }
}
