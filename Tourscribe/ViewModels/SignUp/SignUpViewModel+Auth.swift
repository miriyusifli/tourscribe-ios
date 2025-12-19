import Foundation
import Auth
import SwiftUI

extension SignUpViewModel {
    
    // MARK: - Social Auth
    
    func signUpWithApple() {
        Task { [weak self] in
            await self?.performSocialAuth(provider: .apple)
        }
    }
    
    func signUpWithGoogle() {
        Task { [weak self] in
            await self?.performSocialAuth(provider: .google)
        }
    }
    
    private func performSocialAuth(provider: SocialAuthProvider) async {
        await performAsync { [weak self] in
            guard let self = self else { return }
            
            let user = try await self.authService.signInWithSocial(provider: provider)
            self.authState = AuthState(
                socialUserId: user.id.uuidString,
                email: user.email ?? ""
            )
            self.currentStep = 2 // Skip email/password steps and go to Profile Info
        }
    }
    
    // MARK: - Email Auth
    
    func createAccount() async {
        await performAsync { [weak self] in
            guard let self = self else { return }
            let user = try await self.authService.signUp(email: self.authState.email, password: self.formData.password)
            self.authState.socialUserId = user.id.uuidString
            self.currentStep = 2
        }
    }
    
    // MARK: - Profile Completion
    
    func completeRegistration() async {
        await performAsync { [weak self] in
            guard let self = self else { return }
            guard let userId = self.authState.socialUserId else {
                throw SignUpError.userIdNotFound
            }
            
            let profileData = self.createProfileRequest(userId: userId)
            try await self.authService.updateProfile(userId: userId, data: profileData)
            
            self.signUpSuccess = true
        }
    }
    
    private func createProfileRequest(userId: String) -> ProfileUpdateRequest {
        return ProfileUpdateRequest(
            id: userId,
            email: authState.email,
            firstName: formData.firstName,
            lastName: formData.lastName,
            birthDate: formData.birthDate.formatted(.iso8601.year().month().day()),
            gender: formData.gender,
            interests: formData.selectedInterests.joined(separator: ",")
        )
    }
    
    // MARK: - Async Helper
    
    /// A generic wrapper that handles loading spinners and error alerts for any task
    func performAsync(_ operation: @escaping () async throws -> Void) async {
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            try await operation()
        } catch {
            self.alert = .error(error.localizedDescription)
        }
    }
}
