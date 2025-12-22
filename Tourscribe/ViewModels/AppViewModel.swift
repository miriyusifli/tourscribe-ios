import SwiftUI
import Supabase
import Observation

@Observable
@MainActor
class AppViewModel {
    var isLoggedIn = false
    var isLoading = true
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        checkSession()
    }
    
    func checkSession() {
        Task {
            if let session = await authService.session {
                // Check if a profile exists for the authenticated user
                let profileExists = (try? await authService.getProfile(userId: session.user.id.uuidString)) != nil
                if profileExists {
                    isLoggedIn = true
                }
            }
            isLoading = false
            
            // Listen for logout events
            for await (event, _) in authService.authStateChanges {
                if event == .signedOut {
                    isLoggedIn = false
                }
            }
        }
    }
}
