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
            // Check if there is a valid session stored
            if await authService.session != nil {
                isLoggedIn = true
            }
            isLoading = false
            
            // Listen for future changes (like logout)
            for await (event, _) in authService.authStateChanges {
                switch event {
                case .signedIn:
                    isLoggedIn = true
                case .signedOut:
                    isLoggedIn = false
                default:
                    break
                }
            }
        }
    }
}
