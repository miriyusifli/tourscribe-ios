import SwiftUI
import Combine
import Auth

@Observable
@MainActor
class SignInViewModel {
    
    // MARK: - Properties
    let authService: AuthServiceProtocol
    
    var email = ""
    var password = ""
    var isLoading = false
    var alert: AlertType?
    var signInSuccess = false
    var requiresProfileSetup = false
    var userId: String?
    
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
                let user = try await authService.signIn(email: email, password: password)
                await checkProfileAndProceed(userId: user.id)
            } catch {
                alert = .error(String(localized: "error.generic.unknown"))
            }
        }
    }
    
    func signInWithApple() {
        // TODO: Implement Apple Sign In
        Task { await performSocialAuth(provider: .apple) }
    }
    
    func signInWithGoogle() {
        // TODO: Implement Google Sign In
        Task { await performSocialAuth(provider: .google) }
    }
    
    private func performSocialAuth(provider: SocialAuthProvider) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await authService.signInWithSocial(provider: provider)
            await checkProfileAndProceed(userId: user.id)
        } catch {
            alert = .error(String(localized: "error.generic.unknown"))
        }
    }
    
    private func checkProfileAndProceed(userId: UUID) async {
        self.userId = userId.uuidString
        do {
            if let _ = try await authService.getProfile(userId: userId.uuidString) {
                signInSuccess = true
            } else {
                requiresProfileSetup = true
            }
        } catch {
            alert = .error(String(localized: "error.generic.unknown"))
        }
    }
}
