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
    
    func validateIdentity() -> Bool {
        guard !formData.firstName.isEmpty && !formData.lastName.isEmpty else {
            alert = .validation(SignUpValidationError.missingName.localizedDescription)
            return false
        }
        
        guard formData.gender != "Not Specified" && !formData.gender.isEmpty else {
            alert = .validation(SignUpValidationError.missingGender.localizedDescription)
            return false
        }
        
        // Calculate age
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: formData.birthDate, to: now)
        let age = ageComponents.year ?? 0
        
        guard age >= AppConfig.minimumSignupAge else {
            alert = .validation(SignUpValidationError.underAge(minimum: AppConfig.minimumSignupAge).localizedDescription)
            return false
        }
        
        return true
    }
    
    func validateInterests() -> Bool {
        guard formData.selectedInterests.count >= AppConfig.minimumInterests else {
            alert = .validation(SignUpValidationError.insufficientInterests(minimum: AppConfig.minimumInterests).localizedDescription)
            return false
        }
        return true
    }
}
