import SwiftUI
import Combine

@Observable
@MainActor
class ProfileSetupViewModel {
    // MARK: - Properties
    let authService: AuthServiceProtocol
    let userId: String
    let email: String
    
    var firstName = ""
    var lastName = ""
    var birthDate = Date()
    var gender = ""
    var selectedInterests: Set<String> = []
    
    var isLoading = false
    var alert: AlertType?
    var setupSuccess = false
    
    // Navigation State
    var navigateToInterests = false
    
    // Available interests (Mock data or fetched)
    var interests: [Interest] { Interest.all }
    
    // MARK: - Initialization
    init(authService: AuthServiceProtocol = AuthService(), userId: String, email: String) {
        self.authService = authService
        self.userId = userId
        self.email = email
    }
    
    // MARK: - Actions
    
    func continueToInterests() {
        if validatePersonalInfo() {
            navigateToInterests = true
        }
    }
    
    func completeSetup() {
        if selectedInterests.count < 3 {
            let message = String(format: String(localized: "validation.interests.minimum"), 3)
            alert = .error(message)
            return
        }
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            let request = ProfileUpdateRequest(
                id: userId,
                email: email,
                firstName: firstName,
                lastName: lastName,
                birthDate: birthDate,
                gender: gender,
                interests: Array(selectedInterests)
            )
            
            do {
                try await authService.updateProfile(userId: userId, data: request)
                setupSuccess = true
            } catch {
                alert = .error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Validation
    
    private func validatePersonalInfo() -> Bool {
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
           lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alert = .error(String(localized: "validation.name.missing"))
            return false
        }
        
        if gender.isEmpty {
            alert = .error(String(localized: "validation.gender.missing"))
            return false
        }
        
        // Validate Age (Minimum 12 years old)
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        let age = ageComponents.year ?? 0
        
        if age < 12 {
            let message = String(format: String(localized: "validation.age.minimum"), 12)
            alert = .error(message)
            return false
        }
        
        return true
    }
}
