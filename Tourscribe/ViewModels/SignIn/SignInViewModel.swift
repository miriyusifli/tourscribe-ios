import SwiftUI
import Foundation

@Observable
@MainActor
class SignInViewModel {
    
    private let authService: AuthServiceProtocol
    
    var isLoading = false
    var alert: AlertType?
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
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
        } catch {
            alert = .error(String(localized: "error.generic.unknown"))
        }
    }
}
