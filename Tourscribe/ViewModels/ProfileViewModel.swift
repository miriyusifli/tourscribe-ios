import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile
    
    init() {
        self.user = UserProfile(
            name: "Alex Wanderer",
            handle: "@alex_w",
            rank: "Gold",
            imageName: "person.crop.circle.fill",
            stats: []
        )
    }
    
    func editProfile() {
        // TODO: Edit profile logic
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
