//
//  RegisterView.swift
//  BobTheBuilder
//
//  Created on November 10, 2025.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case firstName, lastName, email, phone, password, confirmPassword
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.viewState.isLoading {
                    loadingOverlay
                } else {
                    registerForm
                }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Registration Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    private var registerForm: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.top, 20)

                    Text("Join Bob the Builder")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Create your account to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Form Fields
                VStack(spacing: 16) {
                    // First Name
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("First Name", text: $viewModel.firstName)
                            .textFieldStyle(CustomTextFieldStyle(
                                systemImage: "person",
                                isError: viewModel.firstNameError != nil
                            ))
                            .textContentType(.givenName)
                            .focused($focusedField, equals: .firstName)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .lastName }

                        if let error = viewModel.firstNameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Last Name
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Last Name", text: $viewModel.lastName)
                            .textFieldStyle(CustomTextFieldStyle(
                                systemImage: "person",
                                isError: viewModel.lastNameError != nil
                            ))
                            .textContentType(.familyName)
                            .focused($focusedField, equals: .lastName)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .email }

                        if let error = viewModel.lastNameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Email
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
                            .onSubmit { focusedField = .phone }

                        if let error = viewModel.emailError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Phone (Optional)
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Phone Number (Optional)", text: $viewModel.phone)
                            .textFieldStyle(CustomTextFieldStyle(
                                systemImage: "phone",
                                isError: false
                            ))
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                            .focused($focusedField, equals: .phone)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                    }

                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack(alignment: .trailing) {
                            if viewModel.isPasswordVisible {
                                TextField("Password", text: $viewModel.password)
                                    .textFieldStyle(CustomTextFieldStyle(
                                        systemImage: "lock",
                                        isError: viewModel.passwordError != nil
                                    ))
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .confirmPassword }
                            } else {
                                SecureField("Password", text: $viewModel.password)
                                    .textFieldStyle(CustomTextFieldStyle(
                                        systemImage: "lock",
                                        isError: viewModel.passwordError != nil
                                    ))
                                    .textContentType(.newPassword)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .confirmPassword }
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
                        } else if !viewModel.password.isEmpty {
                            PasswordStrengthView(password: viewModel.password)
                        }
                    }

                    // Confirm Password
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack(alignment: .trailing) {
                            if viewModel.isConfirmPasswordVisible {
                                TextField("Confirm Password", text: $viewModel.confirmPassword)
                                    .textFieldStyle(CustomTextFieldStyle(
                                        systemImage: "lock",
                                        isError: viewModel.confirmPasswordError != nil
                                    ))
                                    .textContentType(.newPassword)
                                    .focused($focusedField, equals: .confirmPassword)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        Task {
                                            await viewModel.register()
                                        }
                                    }
                            } else {
                                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                                    .textFieldStyle(CustomTextFieldStyle(
                                        systemImage: "lock",
                                        isError: viewModel.confirmPasswordError != nil
                                    ))
                                    .textContentType(.newPassword)
                                    .focused($focusedField, equals: .confirmPassword)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        Task {
                                            await viewModel.register()
                                        }
                                    }
                            }

                            Button(action: {
                                viewModel.isConfirmPasswordVisible.toggle()
                            }) {
                                Image(systemName: viewModel.isConfirmPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 15)
                            }
                            .buttonStyle(.plain)
                        }

                        if let error = viewModel.confirmPasswordError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Register Button
                Button(action: {
                    Task {
                        await viewModel.register()
                    }
                }) {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canRegister ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: viewModel.canRegister ? 2 : 0)
                }
                .disabled(!viewModel.canRegister)
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Terms
                Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer(minLength: 20)
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

                Text("Creating your account...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(30)
            .background(Color.black.opacity(0.7))
            .cornerRadius(15)
        }
    }
}

// MARK: - Password Strength View

struct PasswordStrengthView: View {
    let password: String

    var strength: PasswordStrength {
        if password.isEmpty {
            return .none
        } else if password.count < 6 {
            return .weak
        } else if password.count < 8 {
            return .medium
        } else if password.count >= 8 && containsNumberAndSpecialChar {
            return .strong
        } else {
            return .medium
        }
    }

    var containsNumberAndSpecialChar: Bool {
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChar = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
        return hasNumber && hasSpecialChar
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Rectangle()
                        .fill(index < strength.level ? strength.color : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }

            Text(strength.text)
                .font(.caption)
                .foregroundColor(strength.color)
        }
    }
}

enum PasswordStrength {
    case none, weak, medium, strong

    var level: Int {
        switch self {
        case .none: return 0
        case .weak: return 1
        case .medium: return 2
        case .strong: return 3
        }
    }

    var text: String {
        switch self {
        case .none: return ""
        case .weak: return "Weak password"
        case .medium: return "Medium password"
        case .strong: return "Strong password"
        }
    }

    var color: Color {
        switch self {
        case .none: return .clear
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        }
    }
}

// MARK: - View Model

import Combine

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var viewState: ViewState<Bool> = .idle
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isPasswordVisible = false
    @Published var isConfirmPasswordVisible = false

    // Validation errors
    @Published var firstNameError: String?
    @Published var lastNameError: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?

    private var cancellables = Set<AnyCancellable>()
    private let authManager = AuthManager.shared

    init() {
        setupValidation()
    }

    private func setupValidation() {
        // First Name validation
        $firstName
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] name in
                if !name.isEmpty && name.count < 2 {
                    self?.firstNameError = "First name is too short"
                } else {
                    self?.firstNameError = nil
                }
            }
            .store(in: &cancellables)

        // Last Name validation
        $lastName
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] name in
                if !name.isEmpty && name.count < 2 {
                    self?.lastNameError = "Last name is too short"
                } else {
                    self?.lastNameError = nil
                }
            }
            .store(in: &cancellables)

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

        // Confirm Password validation
        $confirmPassword
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] confirmPassword in
                self?.validateConfirmPassword(confirmPassword)
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
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters"
        } else {
            passwordError = nil
        }
    }

    private func validateConfirmPassword(_ confirmPassword: String) {
        if confirmPassword.isEmpty {
            confirmPasswordError = nil
        } else if password != confirmPassword {
            confirmPasswordError = "Passwords do not match"
        } else {
            confirmPasswordError = nil
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    var canRegister: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        firstNameError == nil &&
        lastNameError == nil &&
        emailError == nil &&
        passwordError == nil &&
        confirmPasswordError == nil &&
        !viewState.isLoading
    }

    func register() async {
        guard canRegister else { return }

        viewState = .loading
        errorMessage = ""
        showError = false

        do {
            try await authManager.register(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )

            // Clear form
            firstName = ""
            lastName = ""
            email = ""
            phone = ""
            password = ""
            confirmPassword = ""

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
}

// MARK: - Previews

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
