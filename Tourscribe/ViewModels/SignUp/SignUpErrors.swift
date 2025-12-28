import Foundation

enum SignUpError: LocalizedError {
    case userIdNotFound
    case selfDeallocated
    case userAlreadyExists
    case weakPassword
    
    var errorDescription: String? {
        switch self {
        case .userIdNotFound:
            return String(localized: "error.signup.userid_missing")
        case .selfDeallocated:
            return String(localized: "error.generic.unknown")
        case .userAlreadyExists:
            return String(localized: "error.signup.user_exists")
        case .weakPassword:
            return String(localized: "error.signup.weak_password")
        }
    }
}

enum SignUpValidationError: LocalizedError {
    case invalidEmail
    case passwordTooShort
    case insufficientInterests(minimum: Int)
    case missingName
    case missingGender
    case underAge(minimum: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return String(localized: "validation.email.invalid")
        case .passwordTooShort:
            return String(localized: "validation.password.short")
        case .insufficientInterests(let minimum):
            let message = String(localized: "validation.interests.minimum")
            return String(format: message, minimum)
        case .missingName:
            return String(localized: "validation.name.missing")
        case .missingGender:
            return String(localized: "validation.gender.missing")
        case .underAge(let minimum):
            let message = String(localized: "validation.age.minimum")
            return String(format: message, minimum)
        }
    }
}
