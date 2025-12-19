import Foundation

// MARK: - View State Models

/// Tracks if the user is using Social Login (Google/Apple) or Email
struct AuthState {
    var socialUserId: String?
    var email: String = ""
}

/// Stores all the information the user types into the form
struct SignUpFormData {
    var password: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var birthDate: Date = Date()
    var gender: String = ""
    var selectedInterests: Set<String> = []
}
