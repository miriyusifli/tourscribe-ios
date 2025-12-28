import SwiftUI
import Supabase
import Observation

@Observable
@MainActor
class AppViewModel {
    var isLoading = true
    var userProfile: UserProfile?
    var sessionUserId: String?
    var sessionEmail: String?
    var requiresProfileSetup = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        listenForAuthChanges()
    }
    
    private func loadProfile(userId: UUID, email: String?) async {
        if let profile = try? await authService.getProfile(userId: userId.uuidString) {
            userProfile = profile
            requiresProfileSetup = false
        } else {
            sessionUserId = userId.uuidString
            sessionEmail = email ?? ""
            requiresProfileSetup = true
        }
        isLoading = false
    }
    
    func onProfileCreated(_ profile: UserProfile) {
        userProfile = profile
        requiresProfileSetup = false
        sessionUserId = nil
        sessionEmail = nil
    }
    
    private func listenForAuthChanges() {
        Task {
            for await (event, session) in authService.authStateChanges {
                switch event {
                case .initialSession:
                    if let session {
                        await loadProfile(userId: session.user.id, email: session.user.email)
                    } else {
                        isLoading = false
                    }
                case .signedIn:
                    if let session {
                        await loadProfile(userId: session.user.id, email: session.user.email)
                    }
                case .signedOut:
                    userProfile = nil
                    requiresProfileSetup = false
                    sessionUserId = nil
                    sessionEmail = nil
                default:
                    break
                }
            }
        }
    }
}
