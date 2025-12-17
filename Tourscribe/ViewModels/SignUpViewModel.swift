import Foundation
import SwiftUI
import Combine

class SignUpViewModel: ObservableObject {
    @Published var currentStep = 0
    
    // Step 1: Credentials
    @Published var email = ""
    @Published var password = ""
    
    // Step 2: Identity
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var birthDate = Date()
    @Published var gender = "Not Specified"
    
    // Step 3: Interests
    @Published var selectedInterests: Set<String> = []
    
    // Auto-detected
    var selectedLocale = Locale.current.language.languageCode?.identifier ?? "en"
    
    // Interests data
    let interests = [
        ("🏖️", "Beach", "Relax by the waves"),
        ("🏔️", "Mountains", "Conquer peaks"),
        ("🏛️", "Culture", "Explore history"),
        ("🍜", "Food", "Taste the world"),
        ("🎨", "Art", "Museum hopper"),
        ("🌃", "Nightlife", "Party vibes"),
        ("🏕️", "Adventure", "Thrill seeker"),
        ("🛍️", "Shopping", "Retail therapy"),
        ("📸", "Photography", "Capture moments"),
        ("🧘", "Wellness", "Find your zen")
    ]
    
    // Email validation
    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func nextStep() {
        if currentStep < 3 {
            if currentStep == 0 {
                withAnimation(nil) {
                    currentStep += 1
                }
            } else {
                currentStep += 1
            }
        } else {
            signUp()
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func titleForStep(_ step: Int) -> String {
        switch step {
        case 0: return "Join Tourscribe"
        case 1: return "Account Info"
        case 2: return "Personal Info"
        case 3: return "Choose Your Vibe"
        default: return ""
        }
    }
    
    private func signUp() {
        // TODO: Integrate authentication service
        print("Signing up user: \(email)")
        print("Selected interests: \(selectedInterests)")
    }
}
