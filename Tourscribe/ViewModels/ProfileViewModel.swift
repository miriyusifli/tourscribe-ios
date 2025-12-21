import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile
    @Published var alert: AlertType?
    
    init() {
        // TODO: Load user profile from AuthService
        self.user = UserProfile(
            id: UUID().uuidString,
            email: "alex@example.com",
            firstName: "Alex",
            lastName: "Wanderer",
            birthDate: Date(),
            gender: "Male",
            interests: [],
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    func editProfile() {
        if validate() {
            // TODO: Edit profile logic
        }
    }
    
    private func validate() -> Bool {
        // 1. Validate Age (Minimum 12 years old)
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: user.birthDate, to: Date())
        let age = ageComponents.year ?? 0
        
        if age < 12 {
            let message = String(format: String(localized: "validation.age.minimum"), 12)
            alert = .error(message)
            return false
        }
        
        // 2. Validate Interests (At least 3 selected)
        if user.interests.count < 3 {
            let message = String(format: String(localized: "validation.interests.minimum"), 3)
            alert = .error(message)
            return false
        }
        
        return true
    }
    
    func openNotifications() {
        // TODO: Notifications logic
    }
    
    func openPrivacy() {
        // TODO: Privacy logic
    }
    
    func openHelp() {
        // TODO: Help logic
    }
    
    func logout() {
        // TODO: Logout logic
    }
}
