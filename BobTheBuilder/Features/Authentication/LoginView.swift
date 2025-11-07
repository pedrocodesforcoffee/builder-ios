//
//  LoginView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var coordinator = AppCoordinator.shared

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.viewState.isLoading {
                    LoadingStateView(message: "Signing in...")
                } else {
                    loginForm
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("Login Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .navigationViewStyle(.stack)
    }

    private var loginForm: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "hammer.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)

                    Text("Bob the Builder")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Build Better Together")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)

                // Login Form
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(CustomTextFieldStyle(systemImage: "envelope"))
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(CustomTextFieldStyle(systemImage: "lock"))
                        .textContentType(.password)

                    Button(action: {
                        // Placeholder for forgot password
                    }) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)

                Spacer()

                // Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.login()
                    }) {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canLogin ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!viewModel.canLogin)

                    Button(action: {
                        coordinator.login() // Skip login for development
                    }) {
                        Text("Skip Login (Dev)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    HStack {
                        Text("Don't have an account?")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        Button(action: {
                            // Placeholder for sign up
                        }) {
                            Text("Sign Up")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Login View Model

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var viewState: ViewState<Bool> = .idle
    @Published var showError = false
    @Published var errorMessage = ""

    var canLogin: Bool {
        !email.isEmpty && !password.isEmpty
    }

    func login() {
        guard canLogin else { return }

        viewState = .loading

        // Simulate API call
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

            await MainActor.run {
                // For now, always show error (no backend yet)
                viewState = .error(APIError.unauthorized)
                errorMessage = "Login functionality not yet implemented. Use 'Skip Login (Dev)' to continue."
                showError = true
            }
        }
    }
}

// MARK: - Previews

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
