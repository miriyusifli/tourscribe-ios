import Foundation

enum SignUpError: LocalizedError {
    case userIdNotFound
    case selfDeallocated
    
    var errorDescription: String? {
        switch self {
        case .userIdNotFound:
            return String(localized: "error.signup.userid_missing")
        case .selfDeallocated:
            return String(localized: "error.generic.unknown")
        }
    }
}

enum SignUpValidationError: LocalizedError {
    case invalidEmail
    case passwordTooShort
    case insufficientInterests(minimum: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return String(localized: "validation.email.invalid")
        case .passwordTooShort:
            return String(localized: "validation.password.short")
        case .insufficientInterests(let minimum):
            let message = String(localized: "validation.interests.minimum")
            return String(format: message, minimum)
        }
    }
}
