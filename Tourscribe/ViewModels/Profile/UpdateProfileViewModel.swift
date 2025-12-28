import SwiftUI
import Combine


@MainActor
class UpdateProfileViewModel: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var birthDate: Date
    @Published var gender: String
    @Published var alert: AlertType?
    @Published var isLoading = false
    
    private let user: UserProfile
    private let authService: AuthServiceProtocol
    var onUpdate: ((UserProfile) -> Void)?
    
    init(user: UserProfile, authService: AuthServiceProtocol = AuthService()) {
        self.user = user
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.birthDate = user.birthDate
        self.gender = user.gender
        self.authService = authService
    }
    
    func update() {
        let request: ProfileUpdateRequest
        do {
            request = try ProfileUpdateRequest(
                firstName: firstName,
                lastName: lastName,
                birthDate: birthDate,
                gender: gender,
                version: user.version
            )
        } catch {
            alert = .error(error.localizedDescription)
            return
        }
        
        Task {
            isLoading = true
            do {
                try await authService.updateProfile(userId: user.id, data: request)
                let updatedProfile = UserProfile(
                    id: user.id,
                    email: user.email,
                    firstName: firstName,
                    lastName: lastName,
                    birthDate: birthDate,
                    gender: gender,
                    interests: user.interests,
                    version: user.version + 1,
                    createdAt: user.createdAt,
                    updatedAt: Date()
                )
                isLoading = false
                onUpdate?(updatedProfile)
            } catch let error as ProfileValidationError {
                isLoading = false
                alert = .error(error.localizedDescription)
            } catch let error as OptimisticLockError {
                isLoading = false
                alert = .error(error.localizedDescription)
            } catch {
                isLoading = false
                alert = .error(String(localized: "error.generic"))
            }
        }
    }
}
