import Foundation
import Combine

extension SignUpViewModel {
    
    // MARK: - Validation Setup
    
    func setupValidation() {
        emailSubject
            .sink { [weak self] _ in
                self?.isEmailValid = true
            }
            .store(in: &cancellables)
        
        passwordSubject
            .removeDuplicates()
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .map { ValidationHelper.isValidPassword($0) }
            .sink { [weak self] isValid in
                self?.isPasswordValid = isValid
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Validation Checks
    
    func validateCredentials() -> Bool {
        // Validate email explicitly on button click
        let isEmailValidNow = ValidationHelper.isValidEmail(email)
        self.isEmailValid = isEmailValidNow
        
        guard isEmailValidNow else {
            alert = .validation(SignUpValidationError.invalidEmail.localizedDescription)
            return false
        }
        guard isPasswordValid else {
            alert = .validation(SignUpValidationError.passwordTooShort.localizedDescription)
            return false
        }
        return true
    }
    
    func validateInterests() -> Bool {
        guard formData.selectedInterests.count >= minimumInterests else {
            alert = .validation(SignUpValidationError.insufficientInterests(minimum: minimumInterests).localizedDescription)
            return false
        }
        return true
    }
}
