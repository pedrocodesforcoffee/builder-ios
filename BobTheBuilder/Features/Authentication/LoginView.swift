//
//  LoginView.swift
//  BobTheBuilder
//
//  Created by Bob the Builder Team
//  Copyright © 2024 Bob the Builder Project. All rights reserved.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var coordinator = AppCoordinator.shared
    @FocusState private var focusedField: Field?
    @State private var showingBiometricOption = false
    @State private var biometricType: LABiometryType = .none

    enum Field: Hashable {
        case email
        case password
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if viewModel.viewState.isLoading {
                    loadingOverlay
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
            .onAppear {
                checkBiometricAvailability()
                checkForSavedCredentials()
            }
        }
        .navigationViewStyle(.stack)
    }

    private var loginForm: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 20) {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(-10))
                        .padding(.top, 60)

                    Text("Bob the Builder")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Build Better Together")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)

                // Form
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(CustomTextFieldStyle(
                                systemImage: "envelope",
                                isError: viewModel.emailError != nil
                            ))
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }

                        if let error = viewModel.emailError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .transition(.opacity)
                        }
                    }

                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack(alignment: .trailing) {
                            if viewModel.isPasswordVisible {
                                TextField("Password", text: $viewModel.password)
                                    .textFieldStyle(CustomTextFieldStyle(
                                        systemImage: "lock",
                                        isError: viewModel.passwordError != nil
                                    ))
                                    .textContentType(.password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        Task {
                                            viewModel.login()
                                        }
                                    }
                            } else {
                                SecureField("Password", text: $viewModel.password)
                                    .textFieldStyle(CustomTextFieldStyle(
                                        systemImage: "lock",
                                        isError: viewModel.passwordError != nil
                                    ))
                                    .textContentType(.password)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        Task {
                                            viewModel.login()
                                        }
                                    }
                            }

                            Button(action: {
                                viewModel.isPasswordVisible.toggle()
                            }) {
                                Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 15)
                            }
                            .buttonStyle(.plain)
                        }

                        if let error = viewModel.passwordError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .transition(.opacity)
                        }
                    }

                    // Forgot Password
                    Button(action: {
                        // TODO: Implement forgot password
                    }) {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 40)

                // Buttons
                VStack(spacing: 16) {
                    // Login Button
                    Button(action: {
                        Task {
                            viewModel.login()
                        }
                    }) {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canLogin ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: viewModel.canLogin ? 2 : 0)
                    }
                    .disabled(!viewModel.canLogin)
                    .scaleEffect(viewModel.canLogin ? 1.0 : 0.98)
                    .animation(.easeInOut(duration: 0.1), value: viewModel.canLogin)

                    // Biometric Login (if available and credentials saved)
                    if biometricType != .none && showingBiometricOption {
                        Button(action: {
                            authenticateWithBiometric()
                        }) {
                            HStack {
                                Image(systemName: biometricIcon)
                                Text("Sign in with \(biometricText)")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                        }
                    }

                    // Sign Up
                    HStack {
                        Text("Don't have an account?")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        NavigationLink(destination: RegisterView()) {
                            Text("Sign Up")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)

                Text("Signing in...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(30)
            .background(Color.black.opacity(0.7))
            .cornerRadius(15)
        }
    }

    private var biometricIcon: String {
        switch biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "lock"
        }
    }

    private var biometricText: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometric"
        }
    }

    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        }
    }

    private func authenticateWithBiometric() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Sign in to Bob the Builder"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                Task { @MainActor in
                    if success {
                        // Login with saved credentials from Keychain
                        await viewModel.loginWithBiometric(context: context)
                    } else {
                        viewModel.errorMessage = "Biometric authentication failed"
                        viewModel.showError = true
                    }
                }
            }
        }
    }

    private func checkForSavedCredentials() {
        showingBiometricOption = TokenManager.shared.hasSavedCredentials()
    }
}

// MARK: - Login View Model

import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var viewState: ViewState<Bool> = .idle
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isPasswordVisible = false

    // Validation
    @Published var emailError: String?
    @Published var passwordError: String?

    // Biometric
    @Published var showBiometricSetup = false

    private var cancellables = Set<AnyCancellable>()
    private let authManager = AuthManager.shared

    init() {
        setupValidation()
        setupSubscriptions()
    }

    private func setupSubscriptions() {
        // Listen for successful login to offer biometric setup
        authManager.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated && self?.showBiometricSetup == true {
                    self?.offerBiometricSetup()
                }
            }
            .store(in: &cancellables)
    }

    private func setupValidation() {
        // Email validation
        $email
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] email in
                self?.validateEmail(email)
            }
            .store(in: &cancellables)

        // Password validation
        $password
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] password in
                self?.validatePassword(password)
            }
            .store(in: &cancellables)
    }

    private func validateEmail(_ email: String) {
        if email.isEmpty {
            emailError = nil
        } else if !isValidEmail(email) {
            emailError = "Please enter a valid email address"
        } else {
            emailError = nil
        }
    }

    private func validatePassword(_ password: String) {
        if password.isEmpty {
            passwordError = nil
        } else if password.count < 6 {
            passwordError = "Password must be at least 6 characters"
        } else {
            passwordError = nil
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    var canLogin: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        emailError == nil &&
        passwordError == nil &&
        !viewState.isLoading
    }

    func login() {
        guard canLogin else { return }

        viewState = .loading
        errorMessage = ""
        showError = false

        Task {
            do {
                try await authManager.login(email: email, password: password)

                // Clear form
                email = ""
                password = ""

                // Offer biometric setup for first-time login
                if !TokenManager.shared.hasSavedCredentials() {
                    showBiometricSetup = true
                }

            } catch let error as AuthError {
                handleAuthError(error)
            } catch {
                handleAuthError(.unknown)
            }

            viewState = .idle
        }
    }

    // Biometric login method
    func loginWithBiometric(context: LAContext) async {
        viewState = .loading

        do {
            try await authManager.loginWithBiometric(context: context)
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            handleAuthError(.unknown)
        }

        viewState = .idle
    }

    private func handleAuthError(_ error: AuthError) {
        errorMessage = error.localizedDescription
        showError = true
    }

    private func offerBiometricSetup() {
        // This would trigger a UI prompt to enable biometric
        // Implementation depends on UI requirements
    }
}

// MARK: - Previews

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
