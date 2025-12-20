import Foundation
import SwiftUI
import Auth
import Combine

// MARK: - View State Models

/// Tracks the entire state of the sign-up form and authentication context
struct SignUpState {
    var socialUserId: String?
    var email: String = ""
    var password: String = ""
    
    var isSocialSignUp: Bool { socialUserId != nil }
}

@Observable
@MainActor
class SignUpViewModel {
    
    // MARK: - Internal Configuration
    private let authService: AuthServiceProtocol
    private let passwordSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Properties
    var shouldNavigateToProfileSetup = false
    
    var state = SignUpState() {
        didSet {
            if state.email != oldValue.email {
                // Reset validation state when user edits email
                isEmailValid = true
            }
            if state.password != oldValue.password {
                passwordSubject.send(state.password)
            }
        }
    }
    
    var isLoading = false
    var alert: AlertType?
    var signUpSuccess = false
    var isEmailValid = false
    var isPasswordValid = false
    
    // MARK: - View Bindings
    var email: String {
        get { state.email }
        set { state.email = newValue.lowercased() }
    }
    
    var password: String {
        get { state.password }
        set { state.password = newValue }
    }
    
    var passwordStrength: (label: String, color: Color, level: Int) {
        PasswordStrengthAnalyzer.checkStrength(password: password)
    }
    
    // MARK: - Initialization
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        setupValidation()
    }
    
    // MARK: - Actions
    
    func createAccount() {
        if validateCredentials() {
            Task { await performAccountCreation() }
        }
    }
    
    func signUp(with provider: SocialAuthProvider) {
        Task { [weak self] in
            await self?.performSocialAuth(provider: provider)
        }
    }
    
    // MARK: - Authentication Logic
    
    private func performSocialAuth(provider: SocialAuthProvider) async {
        await performAsync { [weak self] in
            guard let self = self else { return }
            
            let user = try await self.authService.signInWithSocial(provider: provider)
            self.handleAuthSuccess(user: user)
        }
    }
    
    private func performAccountCreation() async {
        await performAsync { [weak self] in
            guard let self = self else { return }
            
            // Strictly Sign Up (New User path)
            let user = try await self.authService.signUp(email: self.state.email, password: self.state.password)
            self.handleAuthSuccess(user: user)
        }
    }
    
    private func handleAuthSuccess(user: User) {
        state.socialUserId = user.id.uuidString
        if let email = user.email {
            state.email = email
        }
        shouldNavigateToProfileSetup = true
    }
    
    // MARK: - Validation Setup
    
    private func setupValidation() {
        passwordSubject
            .removeDuplicates()
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .map { ValidationHelper.isValidPassword($0) }
            .sink { [weak self] isValid in
                self?.isPasswordValid = isValid
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Validation Checks
    
    func validateCredentials() -> Bool {
        // Validate email explicitly on button click
        let isEmailValidNow = ValidationHelper.isValidEmail(email)
        self.isEmailValid = isEmailValidNow
        
        guard isEmailValidNow else {
            alert = .validation(SignUpValidationError.invalidEmail.localizedDescription)
            return false
        }
        guard isPasswordValid else {
            alert = .validation(SignUpValidationError.passwordTooShort.localizedDescription)
            return false
        }
        return true
    }
    
    // MARK: - Helpers
    
    /// A generic wrapper that handles loading spinners and error alerts for any task
    private func performAsync(_ operation: @escaping () async throws -> Void) async {
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            try await operation()
        } catch is CancellationError {
            // Ignore cancellation
        } catch {
            self.alert = .error(error.localizedDescription)
        }
    }
}
