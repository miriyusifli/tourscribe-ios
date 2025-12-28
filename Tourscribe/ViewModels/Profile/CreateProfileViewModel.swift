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
    
    var createdProfile: UserProfile?
    
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
        do {
            _ = try ProfileCreateRequest(
                id: userId,
                email: email,
                firstName: firstName,
                lastName: lastName,
                birthDate: birthDate,
                gender: gender,
                interests: Array(selectedInterests)
            )
            navigateToInterests = true
        } catch ProfileValidationError.insufficientInterests {
            // Ignore interests validation at this step
            navigateToInterests = true
        } catch {
            alert = .error(error.localizedDescription)
        }
    }
    
    func completeSetup() {
        let request: ProfileCreateRequest
        do {
            request = try ProfileCreateRequest(
                id: userId,
                email: email,
                firstName: firstName,
                lastName: lastName,
                birthDate: birthDate,
                gender: gender,
                interests: Array(selectedInterests)
            )
        } catch {
            alert = .error(error.localizedDescription)
            return
        }
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                createdProfile = try await authService.createProfile(data: request)
                setupSuccess = true
            } catch {
                alert = .error(String(localized: "error.generic.unknown"))
            }
        }
    }
}
