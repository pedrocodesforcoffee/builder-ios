//
//  LoginView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var coordinator = AppCoordinator.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

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

                        Text("Sign in to continue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)

                    // Login Form
                    VStack(spacing: 16) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }

                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.password)
                        }

                        // Forgot Password
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                // Future: Show forgot password flow
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.horizontal, 32)

                    // Login Button
                    Button(action: {
                        performLogin()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(loginButtonColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isLoading)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                        Text("OR")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 32)

                    // Social Login Buttons
                    VStack(spacing: 12) {
                        SocialLoginButton(
                            icon: "apple.logo",
                            title: "Continue with Apple",
                            backgroundColor: .black
                        ) {
                            // Future: Apple Sign In
                        }

                        SocialLoginButton(
                            icon: "envelope.fill",
                            title: "Continue with Google",
                            backgroundColor: .red
                        ) {
                            // Future: Google Sign In
                        }
                    }
                    .padding(.horizontal, 32)

                    // Sign Up
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        Button("Sign Up") {
                            // Future: Show sign up flow
                        }
                    }
                    .font(.subheadline)
                    .padding(.top, 8)

                    Spacer()

                    // Placeholder Note
                    Text("This is a placeholder login view.\nTap 'Sign In' with any credentials to continue.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                }
            }
        }
        .alert("Login Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }

    private var loginButtonColor: Color {
        isFormValid && !isLoading ? .blue : .gray
    }

    private func performLogin() {
        isLoading = true

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            // Placeholder: Accept any credentials
            coordinator.login()
        }
    }
}

struct SocialLoginButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
