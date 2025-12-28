import SwiftUI
import Auth
import Foundation

@Observable
@MainActor
class SignInViewModel {
    
    // MARK: - Properties
    private let authService: AuthServiceProtocol
    
    var email = ""
    var password = ""
    var isLoading = false
    var alert: AlertType?
    
    // MARK: - Initialization
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    // MARK: - Actions
    
    func signIn() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                _ = try await authService.signIn(email: email, password: password)
                // authStateChanges handles navigation
            } catch let error as Auth.AuthError {
                if case .invalidCredentials = error.errorCode {
                    alert = .error(String(localized: "error.auth.invalid_credentials"))
                } else {
                    alert = .error(String(localized: "error.generic.unknown"))
                }
            } catch {
                alert = .error(String(localized: "error.generic.unknown"))
            }
        }
    }
    
    func signInWithApple() {
        Task { await performSocialAuth(provider: .apple) }
    }
    
    func signInWithGoogle() {
        Task { await performSocialAuth(provider: .google) }
    }
    
    private func performSocialAuth(provider: SocialAuthProvider) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await authService.signInWithSocial(provider: provider)
            // authStateChanges handles navigation
        } catch {
            alert = .error(String(localized: "error.generic.unknown"))
        }
    }
}
