import Foundation
import SwiftUI
import Auth
import Combine

@Observable
@MainActor
class SignUpViewModel {
    
    // MARK: - Internal Configuration
    // Visible to extensions
    let minimumInterests = 3
    let authService: AuthServiceProtocol
    let emailSubject = PassthroughSubject<String, Never>()
    let passwordSubject = PassthroughSubject<String, Never>()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Properties
    var currentStep = 0
    
    var authState = AuthState() {
        didSet {
            if authState.email != oldValue.email {
                emailSubject.send(authState.email)
            }
        }
    }
    
    var formData = SignUpFormData() {
        didSet {
            if formData.password != oldValue.password {
                passwordSubject.send(formData.password)
            }
        }
    }
    
    var isLoading = false
    var alert: AlertType?
    var signUpSuccess = false
    var isEmailValid = false
    var isPasswordValid = false
    
    // MARK: - View Bindings
    var email: String {
        get { authState.email }
        set { authState.email = newValue.lowercased() }
    }
    
    var password: String {
        get { formData.password }
        set { formData.password = newValue }
    }
    
    var firstName: String {
        get { formData.firstName }
        set { formData.firstName = newValue }
    }
    
    var lastName: String {
        get { formData.lastName }
        set { formData.lastName = newValue }
    }
    
    var birthDate: Date {
        get { formData.birthDate }
        set { formData.birthDate = newValue }
    }
    
    var gender: String {
        get { formData.gender }
        set { formData.gender = newValue }
    }
    
    var selectedInterests: Set<String> {
        get { formData.selectedInterests }
        set { formData.selectedInterests = newValue }
    }

    var interests: [Interest] { Interest.all }
    
    // MARK: - Initialization
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        setupValidation()
    }
}
