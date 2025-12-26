import SwiftUI
import Supabase
import Observation

@Observable
@MainActor
class AppViewModel {
    var isLoggedIn = false
    var isLoading = true
    var userProfile: UserProfile?
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        checkSession()
    }
    
    func checkSession() {
        Task {
            if let session = await authService.session {
                if let profile = try? await authService.getProfile(userId: session.user.id.uuidString) {
                    userProfile = profile
                    isLoggedIn = true
                }
            }
            isLoading = false
            
            // Listen for logout events
            for await (event, _) in authService.authStateChanges {
                if event == .signedOut {
                    userProfile = nil
                    isLoggedIn = false
                }
            }
        }
    }
}
