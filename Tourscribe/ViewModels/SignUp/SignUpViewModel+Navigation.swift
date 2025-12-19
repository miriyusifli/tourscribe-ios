import Foundation
import SwiftUI

extension SignUpViewModel {
    
    // MARK: - Navigation Logic
    
    func nextStep() {
        switch currentStep {
        case 1:
            if validateCredentials() {
                Task { await createAccount() }
            }
        case 3:
            if validateInterests() {
                Task { await completeRegistration() }
            }
        default:
            navigateToNextStep()
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func navigateToNextStep() {
        if currentStep < 3 {
            currentStep += 1
        }
    }
    
    // MARK: - View Helpers
    
    func titleForStep(_ step: Int) -> String {
        switch step {
        case 0: return String(localized: "signup.step.welcome.title")
        case 1: return String(localized: "signup.step.credentials.title")
        case 2: return String(localized: "signup.step.identity.title")
        case 3: return String(localized: "signup.step.interests.title")
        default: return ""
        }
    }
}
