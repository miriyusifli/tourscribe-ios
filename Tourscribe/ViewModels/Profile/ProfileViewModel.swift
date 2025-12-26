import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile
    @Published var alert: AlertType?
    @Published var showEditProfile = false
    
    private let authService: AuthServiceProtocol
    
    init(user: UserProfile, authService: AuthServiceProtocol = AuthService()) {
        self.user = user
        self.authService = authService
    }
    
    func editProfile() {
        showEditProfile = true
    }
    
    func logout() {
        Task {
            do {
                try await authService.signOut()
            } catch {
                alert = .error(String(localized: "error.generic.unknown"))
            }
        }
    }
}