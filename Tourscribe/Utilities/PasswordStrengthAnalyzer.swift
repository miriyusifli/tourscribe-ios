import SwiftUI

enum PasswordStrengthAnalyzer {
    
    static func checkStrength(password: String) -> (label: String, color: Color, level: Int) {
        let length = password.count
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecial = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        
        if length == 0 { return ("", .clear, 0) }
        if length < 6 { return ("password.strength.weak", .red, 1) }
        if length >= 8 && hasUppercase && hasNumber { return ("password.strength.strong", .green, 3) }
        if length >= 6 && (hasUppercase || hasNumber || hasSpecial) { return ("password.strength.medium", .orange, 2) }
        return ("password.strength.weak", .red, 1)
    }
}
