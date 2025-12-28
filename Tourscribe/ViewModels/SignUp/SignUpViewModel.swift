import Foundation
import SwiftUI
import Auth
import Combine

// MARK: - View State Models

struct SignUpState {
    var email: String = ""
    var password: String = ""
}

@Observable
@MainActor
class SignUpViewModel {
    
    // MARK: - Internal Configuration
    private let authService: AuthServiceProtocol
    private let passwordSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Properties
    var state = SignUpState() {
        didSet {
            if state.email != oldValue.email {
                isEmailValid = true
            }
            if state.password != oldValue.password {
                passwordSubject.send(state.password)
            }
        }
    }
    
    var isLoading = false
    var alert: AlertType?
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
    
    // MARK: - Authentication Logic
    
    private func performAccountCreation() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await authService.signUp(email: state.email, password: state.password)
        } catch let error as Auth.AuthError {
            switch error.errorCode {
            case .userAlreadyExists:
                alert = .error(SignUpError.userAlreadyExists.localizedDescription)
            case .weakPassword:
                alert = .error(SignUpError.weakPassword.localizedDescription)
            default:
                alert = .error(String(localized: "error.generic.unknown"))
            }
        } catch {
            alert = .error(String(localized: "error.generic.unknown"))
        }
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
}
