import Foundation

enum ProfileValidationError: LocalizedError {
    case emptyFirstName
    case emptyLastName
    case emptyGender
    case underAge
    case insufficientInterests
    
    var errorDescription: String? {
        switch self {
        case .emptyFirstName:
            return String(localized: "validation.first_name.empty")
        case .emptyLastName:
            return String(localized: "validation.last_name.empty")
        case .emptyGender:
            return String(localized: "validation.gender.empty")
        case .underAge:
            return String(format: String(localized: "validation.age.minimum"), AppConfig.minimumSignupAge)
        case .insufficientInterests:
            return String(format: String(localized: "validation.interests.minimum"), AppConfig.minimumInterests)
        }
    }
}
